#include "mix.h"

static void swap(int8_t* a, int8_t* b) {
  int8_t temp = *a;
  *a = *b;
  *b = temp;
}

static void reverse_bytes_range(int8_t* from, int8_t* to) {
  while (from < to) {
    swap(from, to);
    ++from;
    --to;
  }
}

static void reverse_bytes(int8_t* addr, int bytes) {
  reverse_bytes_range(addr, addr + bytes - 1);
}

UNIFEX_TERM mix(UnifexEnv* env, UnifexPayload** tracks, unsigned int tracks_num, int is_signed, int sample_size, int is_big_endian) {
  int bytes_in_sample = sample_size / 8;
  int sequence_length = tracks[0]->size;

  UnifexPayload* mix_payload = unifex_payload_alloc(env, tracks[0]->type, sequence_length);

  int64_t min, max, one = 1;

  if (is_signed) {
    min = -(one << (sample_size - 1));
    max = (one << (sample_size - 1)) - 1;
  } else {
    min = 0;
    max = (one << sample_size) - 1;
  }

  int64_t sign_bit_mask = one << (sample_size - 1);

  for (int offset = 0; offset < sequence_length; offset += bytes_in_sample) {
    int64_t sum = 0;
    for (int track_index = 0; track_index < (int) tracks_num; ++track_index) {
      int64_t now_mixed = 0;
      memcpy(&now_mixed, tracks[track_index]->data + offset, bytes_in_sample);

      // This code assumes it is run on little endian architecture
      // If sample is in big endian, we reverse initial bytes of now_mixed
      if (is_big_endian == 1) {
        reverse_bytes((int8_t*) &now_mixed, bytes_in_sample);
      }
      // If the sample is signed, smaller than 0 we need to set the most significant byte(s)
      // of now_mixed variable to ones
      // An example: we have signed 16-bit little endian sample of value -2
      // Its hex representation:   0xFE 0xFF
      // After copy to now_mixed:  0xFE 0xFF 0x00 0x00 0x00 0x00 0x00 0x00
      // now_mixed has value of 32766.
      // -2 written on 8 bytes is: 0xFE 0xFF 0x11 0x11 0x11 0x11 0x11 0x11
      if (is_signed && (now_mixed & sign_bit_mask)) {
        now_mixed -= (one << sample_size);
      }
      sum += now_mixed;
    }
    if (sum < min) {
      sum = min;
    } else if (sum > max) {
      sum = max;
    }
    if (is_big_endian == 1) {
      reverse_bytes((int8_t*) &sum, bytes_in_sample);
    }
    memcpy(mix_payload->data + offset, &sum, bytes_in_sample);
  }
  UNIFEX_TERM result = mix_result(env, mix_payload);
  unifex_payload_release_ptr(&mix_payload);
  return result;
}

void handle_destroy_state(UnifexEnv* env, State* state) {
  UNIFEX_UNUSED(env);
  UNIFEX_UNUSED(state);
}
