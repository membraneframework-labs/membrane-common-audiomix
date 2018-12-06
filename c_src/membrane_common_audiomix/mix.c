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

static void reverse_bytes(int32_t* n, int bytes) {
  int8_t* addr = (int8_t*) n;
  reverse_bytes_range(addr, addr + bytes - 1);
}

UNIFEX_TERM mix(UnifexEnv* env, UnifexPayload** buffers, unsigned int n, int is_signed, int sample_size, int is_big_endian) {
  int bytes = sample_size / 8;
  int sequence_length = buffers[0]->size;

  UnifexPayload* mix_payload = unifex_payload_alloc(env, buffers[0]->type, sequence_length);

  int64_t min, max, one = 1;

  if (is_signed) {
    min = -(one << (sample_size - 1));
    max = (one << (sample_size - 1)) - 1;
  } else {
    min = 0;
    max = (one << sample_size) - 1;
  }

  int64_t highest_bit = one << (sample_size - 1);

  for (int i = 0; i < sequence_length; i += bytes) {
    int64_t sum = 0;
    for (int j = 0; j < (int) n; ++j) {
      int32_t now = 0;
      memcpy(&now, buffers[j]->data + i, bytes);
      if (is_big_endian == 1) {
        reverse_bytes(&now, bytes);
      }
      if (is_signed && (now & highest_bit)) {
        now -= (one << sample_size);
      }
      sum += now;
    }
    if (sum < min) {
      sum = min;
    }
    if (sum > max) {
      sum = max;
    }
    if (is_signed && sum < 0) {
      sum += (one << sample_size);
    }
    memcpy(mix_payload->data + i, &sum, bytes);
  }
  UNIFEX_TERM result = mix_result(env, mix_payload);
  unifex_payload_release_ptr(&mix_payload);
  return result;
}

void handle_destroy_state(UnifexEnv* env, State* state) {
  UNIFEX_UNUSED(env);
  UNIFEX_UNUSED(state);
}
