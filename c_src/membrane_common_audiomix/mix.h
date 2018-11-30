#pragma once

#define MEMBRANE_LOG_TAG "Membrane.Common.AudioMix.Native"

#include <erl_nif.h>

#include <membrane/membrane.h>
#include <membrane/log.h>
#include <unifex/unifex.h>

typedef struct {} UnifexNifState;
typedef UnifexNifState State;

#include "_generated/mix.h"
