#include "mix.h"

UNIFEX_TERM mix(UnifexEnv* env, UnifexPayload ** buffers, unsigned int n) {
  UnifexPayload * mix_payload
  return unifex_payload_to_term(env, buffers[0]);
}

void handle_destroy_state(UnifexEnv* env, State* state) {}
