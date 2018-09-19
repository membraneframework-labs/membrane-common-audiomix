#pragma GCC optimize("Ofast")
#pragma GCC target("sse,sse2,sse3,ssse3,sse4")
#pragma GCC optimize("unroll-loops")

#include "mix.h"
#include <limits.h>

UNIFEX_TERM mix(UnifexEnv* env, UnifexPayload** buffers, unsigned int n) {
  int sequence_length = buffers[0]->size;
  UnifexPayload* mix_payload = unifex_payload_alloc(env, buffers[0]->type, sequence_length);
  for (int i = 0; i < sequence_length; i += 2) {
    short* now;
    int sum = 0;
    for (int j = 0; j < (int) n; ++j) {
      sum += *((short*)(buffers[j]->data + i));
    }
    if (sum < SHRT_MIN) {
      sum = SHRT_MIN;
    }
    if (sum > SHRT_MAX) {
      sum = SHRT_MAX;
    }
    *((short*)(mix_payload->data + i)) = (short) sum;
  }
  UNIFEX_TERM result = mix_result(env, mix_payload);
  unifex_payload_release_ptr(&mix_payload);
  return result;
}

void handle_destroy_state(UnifexEnv* env, State* state) {}
