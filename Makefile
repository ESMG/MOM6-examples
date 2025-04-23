# Helper Makefile for driving building, running, testing of MOM_parameter_doc files
# in ocean_only, ice_ocean_SIS2, and coupled_AM2_LM3_SIS2.  The real work is done
# by Makefile in those directories.
#
# `make` or `make build`      - builds the ocean_only and ice_ocean_SIS2 executables
# `make gfdl`                 - does the same and also builds coupled_AM2_LM3_SIS2
#                               (this will only work inside the GFDL firewall *and*
#                                with FMS_CODEBASE=src/FMS1)
# `make run.all`              - runs the experiments in  ocean_only. and ice_ocean_SIS2/
#                               (runs are conducted in a sub-directory "scratch" local to
#                                ocean_only/ and ice_ocean_SIS2/, e.g. ocean_only/scratch)
# `make run.gfdl`             - ... also runs the experiments in coupled_AM2_LM3_SIS2/
# `make test.all`             - tests the state of MOM_parameter_doc files for
#                                ocean_only/ and ice_ocean_SIS2/
# `make test.gfdl`            - you guessed it! The same and also for coupled_AM2_LM3_SIS2
#
# Other ways to do things:
#
# `make BUILD=build123`       - will build the executables in MOM6-examples/build123
# `make TESTDIR=tmp`          - will run the executables in ocean_only/tmp/DOME/, etc.
# `make TESTDIR=.`            - will run the executables in place
# `make FMS_CODEBASE=src/FMS1 - will build with FMS1 (FMS2 is the default)

-include config.mk

# Configuration
BUILD ?=
FMS_CODEBASE ?= src/FMS2

# Variable `export` replaces the default autoconf values with empty strings.
# This restores the default values.
CFLAGS ?= -g -O2
FCFLAGS ?= -g -O2

# Pass autoconf environment variables to submakes
export CPPFLAGS
export CC
export MPICC
export CFLAGS
export FC
export MPIFC
export FCFLAGS
export LDFLAGS
export LIBS
export PYTHON

export LAUNCHER
export LAUNCHER_NP_FLAG
export LAUNCHER_FLAGS

# Disable builtin rules and variables
MAKEFLAGS += -rR

#------
# make

# Public models
.PHONY: all
all: build.all
.PHONY: build.all
build build.all: ocean_only ice_ocean_SIS2

# GFDL-specific coupled models (requires access to GFDL intranet)
ifeq ($(FMS_CODEBASE), src/FMS2)
.PHONY: gfdl
gfdl: build.gfdl
build.gfdl:
	echo "The build.gfdl target is not available using FMS_CODEBASE=src/FMS2"
else
.PHONY: gfdl
gfdl: build.gfdl
.PHONY: build.gfdl
build.gfdl: ocean_only ice_ocean_SIS2 coupled_AM2_LM3_SIS2
endif


# If BUILD is defined, override the default values and store as macros.
# These are passed to the submake build/run/test rules.
ifdef BUILD
FMS_BUILD = $(abspath $(BUILD)/fms)
ATMOS_NULL_BUILD = $(abspath $(BUILD)/atmos_null)
AM2_BUILD = $(abspath $(BUILD)/AM2)
LAND_NULL_BUILD = $(abspath $(BUILD)/land_null)
LM3_BUILD = $(abspath $(BUILD)/LM3)
ICEBERGS_BUILD = $(abspath $(BUILD)/icebergs)
ICE_PARAM_BUILD = $(abspath $(BUILD)/ice_param)
OCEAN_ONLY_BUILD = $(abspath $(BUILD)/ocean_only)
ICE_OCEAN_BUILD = $(abspath $(BUILD)/ice_ocean_SIS2)
COUPLED_BUILD = $(abspath $(BUILD)/coupled_AM2_LM3_SIS2)


FMS_BUILDFLAGS = BUILD=$(FMS_BUILD)

ATMOS_NULL_BUILDFLAGS = \
  BUILD=$(ATMOS_NULL_BUILD) \
  FMS_BUILD=$(FMS_BUILD)

AM2_BUILDFLAGS = \
  BUILD=$(AM2_BUILD) \
  FMS_BUILD=$(FMS_BUILD)

LAND_NULL_BUILDFLAGS = \
  BUILD=$(LAND_NULL_BUILD) \
  FMS_BUILD=$(FMS_BUILD)

LM3_BUILDFLAGS = \
  BUILD=$(LM3_BUILD) \
  FMS_BUILD=$(FMS_BUILD)

ICEBERGS_BUILDFLAGS = \
  BUILD=$(ICEBERGS_BUILD) \
  FMS_BUILD=$(FMS_BUILD)

ICE_PARAM_BUILDFLAGS = \
  BUILD=$(ICE_PARAM_BUILD) \
  FMS_BUILD=$(FMS_BUILD)

OCEAN_ONLY_BUILDFLAGS = \
  BUILD=$(OCEAN_ONLY_BUILD) \
  FMS_BUILD=$(FMS_BUILD)

ICE_OCEAN_BUILDFLAGS = \
  BUILD=$(ICE_OCEAN_BUILD) \
  FMS_BUILD=$(FMS_BUILD) \
  ATMOS_BUILD=$(ATMOS_NULL_BUILD) \
  LAND_BUILD=$(LAND_NULL_BUILD) \
  ICEBERGS_BUILD=$(ICEBERGS_BUILD) \
  ICE_PARAM_BUILD=$(ICE_PARAM_BUILD)

COUPLED_BUILDFLAGS = \
  BUILD=$(COUPLED_BUILD) \
  FMS_BUILD=$(FMS_BUILD) \
  AM2_BUILD=$(AM2_BUILD) \
  LM3_BUILD=$(LM3_BUILD) \
  ICEBERGS_BUILD=$(ICEBERGS_BUILD) \
  ICE_PARAM_BUILD=$(ICE_PARAM_BUILD)
else
# These reflect the default build locations used by the Makefile in each of shared/*/,
# ocean_only/, ice_ocean_SIS2/, and coupled_AM2_LM3_SIS2/
FMS_BUILD = shared/fms/build
ATMOS_NULL_BUILD = shared/atmos_null/build
AM2_BUILD = shared/AM2/build
LAND_NULL_BUILD = shared/land_null/build
LM3_BUILD = shared/LM3/build
ICEBERGS_BUILD = shared/icebergs/build
ICE_PARAM_BUILD = shared/ice_param/build
OCEAN_ONLY_BUILD = ocean_only/build
ICE_OCEAN_BUILD = ice_ocean_SIS2/build
COUPLED_BUILD = coupled_AM2_LM3_SIS2/build
endif

.PHONY: ocean_only
ocean_only: $(OCEAN_ONLY_BUILD)/MOM6
$(OCEAN_ONLY_BUILD)/MOM6: $(FMS_BUILD)/libFMS.a
$(OCEAN_ONLY_BUILD)/MOM6: $(wildcard src/MOM6/src/*/*)
$(OCEAN_ONLY_BUILD)/MOM6: $(wildcard src/MOM6/src/*/*/*)
$(OCEAN_ONLY_BUILD)/MOM6: $(wildcard src/MOM6/config_src/memory/*)
$(OCEAN_ONLY_BUILD)/MOM6: $(wildcard src/MOM6/config_src/infra/*/*)
$(OCEAN_ONLY_BUILD)/MOM6: $(wildcard src/MOM6/config_src/external/*/*)
$(OCEAN_ONLY_BUILD)/MOM6: $(wildcard src/MOM6/config_src/drivers/solo_driver/*)
	@echo make[$(MAKELEVEL)] Building target $@ ...
	$(MAKE) -C ocean_only $(OCEAN_ONLY_BUILDFLAGS) FMS_CODEBASE=$(abspath $(FMS_CODEBASE) )
	@echo make[$(MAKELEVEL)] ... done building target $@

.PHONY: ice_ocean_SIS2
ice_ocean_SIS2: $(ICE_OCEAN_BUILD)/coupler_main
$(ICE_OCEAN_BUILD)/coupler_main: $(LAND_NULL_BUILD)/libland_null.a
$(ICE_OCEAN_BUILD)/coupler_main: $(ATMOS_NULL_BUILD)/libatmos_null.a
$(ICE_OCEAN_BUILD)/coupler_main: $(ICE_PARAM_BUILD)/libice_param.a
$(ICE_OCEAN_BUILD)/coupler_main: $(ICEBERGS_BUILD)/libicebergs.a
$(ICE_OCEAN_BUILD)/coupler_main: $(wildcard src/MOM6/src/*/*)
$(ICE_OCEAN_BUILD)/coupler_main: $(wildcard src/MOM6/src/*/*/*)
$(ICE_OCEAN_BUILD)/coupler_main: $(wildcard src/MOM6/config_src/memory/*)
$(ICE_OCEAN_BUILD)/coupler_main: $(wildcard src/MOM6/config_src/infra/*/*)
$(ICE_OCEAN_BUILD)/coupler_main: $(wildcard src/MOM6/config_src/external/*/*)
$(ICE_OCEAN_BUILD)/coupler_main: $(wildcard src/MOM6/config_src/drivers/FMS_cap/*)
	@echo make[$(MAKELEVEL)] Building target $@ ...
	$(MAKE) -C ice_ocean_SIS2 $(ICE_OCEAN_BUILDFLAGS) FMS_CODEBASE=$(abspath $(FMS_CODEBASE) )
	@echo make[$(MAKELEVEL)] ... done building target $@

.PHONY: coupled_AM2_LM3_SIS2
coupled_AM2_LM3_SIS2: $(COUPLED_BUILD)/coupler_main
$(COUPLED_BUILD)/coupler_main: $(AM2_BUILD)/libAM2.a
$(COUPLED_BUILD)/coupler_main: $(LM3_BUILD)/libLM3.a
$(COUPLED_BUILD)/coupler_main: $(ICE_PARAM_BUILD)/libice_param.a
$(COUPLED_BUILD)/coupler_main: $(ICEBERGS_BUILD)/libicebergs.a
$(COUPLED_BUILD)/coupler_main: $(wildcard src/MOM6/src/*/*)
$(COUPLED_BUILD)/coupler_main: $(wildcard src/MOM6/src/*/*/*)
$(COUPLED_BUILD)/coupler_main: $(wildcard src/MOM6/config_src/memory/*)
$(COUPLED_BUILD)/coupler_main: $(wildcard src/MOM6/config_src/infra/*/*)
$(COUPLED_BUILD)/coupler_main: $(wildcard src/MOM6/config_src/external/*/*)
$(COUPLED_BUILD)/coupler_main: $(wildcard src/MOM6/config_src/drivers/FMS_cap/*)
	@echo make[$(MAKELEVEL)] Building target $@ ...
	$(MAKE) -C coupled_AM2_LM3_SIS2 $(COUPLED_BUILDFLAGS) FMS_CODEBASE=$(abspath $(FMS_CODEBASE) )
	@echo make[$(MAKELEVEL)] ... done building target $@

.PHONY: land_null
land_null: $(LAND_NULL_BUILD)/libland_null.a
$(LAND_NULL_BUILD)/libland_null.a: $(FMS_BUILD)/libFMS.a
$(LAND_NULL_BUILD)/libland_null.a: $(wildcard src/land_null/*)
	@echo make[$(MAKELEVEL)] Building target $@ ...
	$(MAKE) -C shared/land_null $(LAND_NULL_BUILDFLAGS) FMS_CODEBASE=$(abspath $(FMS_CODEBASE) )
	@echo make[$(MAKELEVEL)] ... done building target $@

.PHONY: LM3
LM3: $(LM3_BUILD)/libLM3.a
$(LM3_BUILD)/libLM3.a: $(FMS_BUILD)/libFMS.a
$(LM3_BUILD)/libLM3.a: $(wildcard src/LM3/*/* src/LM3/*/*/*)
	@echo make[$(MAKELEVEL)] Building target $@ ...
	$(MAKE) -C shared/LM3 $(LM3_BUILDFLAGS) FMS_CODEBASE=$(abspath $(FMS_CODEBASE) )
	@echo make[$(MAKELEVEL)] ... done building target $@

.PHONY: atmos_null
atmos_null: $(ATMOS_NULL_BUILD)/libatmos_null.a
$(ATMOS_NULL_BUILD)/libatmos_null.a: $(FMS_BUILD)/libFMS.a
$(ATMOS_NULL_BUILD)/libatmos_null.a: $(wildcard src/atmos_null/*)
	@echo make[$(MAKELEVEL)] Building target $@ ...
	$(MAKE) -C shared/atmos_null $(ATMOS_NULL_BUILDFLAGS) FMS_CODEBASE=$(abspath $(FMS_CODEBASE) )
	@echo make[$(MAKELEVEL)] ... done building target $@

.PHONY: AM2
AM2: $(AM2_BUILD)/libAM2.a
$(AM2_BUILD)/libAM2.a: $(FMS_BUILD)/libFMS.a
$(AM2_BUILD)/libAM2.a: $(wildcard src/AM2/*/* src/AM2/*/*/*)
	@echo make[$(MAKELEVEL)] Building target $@ ...
	$(MAKE) -C shared/AM2 $(AM2_BUILDFLAGS) FMS_CODEBASE=$(abspath $(FMS_CODEBASE) )
	@echo make[$(MAKELEVEL)] ... done building target $@

.PHONY: icebergs
icebergs: $(ICEBERGS_BUILD)/libicebergs.a
$(ICEBERGS_BUILD)/libicebergs.a: $(FMS_BUILD)/libFMS.a
$(ICEBERGS_BUILD)/libicebergs.a: $(wildcard src/icebergs/src/*)
	@echo make[$(MAKELEVEL)] Building target $@ ...
	$(MAKE) -C shared/icebergs $(ICEBERGS_BUILDFLAGS) FMS_CODEBASE=$(abspath $(FMS_CODEBASE) )
	@echo make[$(MAKELEVEL)] ... done building target $@

.PHONY: ice_param
ice_param: $(ICE_PARAM_BUILD)/libice_param.a
$(ICE_PARAM_BUILD)/libice_param.a: $(FMS_BUILD)/libFMS.a
$(ICE_PARAM_BUILD)/libice_param.a: $(wildcard src/ice_param/src/*)
	@echo make[$(MAKELEVEL)] Building target $@ ...
	$(MAKE) -C shared/ice_param $(ICE_PARAM_BUILDFLAGS) FMS_CODEBASE=$(abspath $(FMS_CODEBASE) )
	@echo make[$(MAKELEVEL)] ... done building target $@

.PHONY: fms
fms: $(FMS_BUILD)/libFMS.a
$(FMS_BUILD)/libFMS.a: $(wildcard $(FMS_CODEBASE)/*/* $(FMS_CODEBASE)/*/*/*)
	@echo make[$(MAKELEVEL)] Building target $@ ...
	$(MAKE) -C shared/fms $(FMS_BUILDFLAGS) CODEBASE=$(abspath $(FMS_CODEBASE) )
	@echo make[$(MAKELEVEL)] ... done building target $@


#----------
# make run

.PHONY: run.all
run.all: run.ocean_only run.ice_ocean_SIS2

.PHONY: run.gfdl
run.gfdl: run.ocean_only run.ice_ocean_SIS2 run.coupled_AM2_LM3_SIS2

.PHONY: run.ocean_only
run.ocean_only: ocean_only
	$(MAKE) -C ocean_only/ run.all $(OCEAN_ONLY_BUILDFLAGS)

.PHONY: run.ice_ocean_SIS2
run.ice_ocean_SIS2: ice_ocean_SIS2
	$(MAKE) -C ice_ocean_SIS2/ run.all $(ICE_OCEAN_BUILDFLAGS)

.PHONY: run.coupled_AM2_LM3_SIS2
run.coupled_AM2_LM3_SIS2: coupled_AM2_LM3_SIS2
	$(MAKE) -C coupled_AM2_LM3_SIS2/ run.all $(COUPLED_BUILDFLAGS)


#-----------
# make test

.PHONY: test.all
test.all: test.ocean_only test.ice_ocean_SIS2

.PHONY: test.gfdl
test.gfdl: test.ocean_only test.ice_ocean_SIS2 test.coupled_AM2_LM3_SIS2

.PHONY: test.ocean_only
test.ocean_only: run.ocean_only
	$(MAKE) -C ocean_only/ test.all $(OCEAN_ONLY_BUILDFLAGS)

.PHONY: test.ice_ocean_SIS2
test.ice_ocean_SIS2: run.ice_ocean_SIS2
	$(MAKE) -C ice_ocean_SIS2/ test.all $(ICE_OCEAN_BUILDFLAGS)

.PHONY: test.coupled_AM2_LM3_SIS2
test.coupled_AM2_LM3_SIS2: run.coupled_AM2_LM3_SIS2
	$(MAKE) -C coupled_AM2_LM3_SIS2/ test.all $(COUPLED_BUILDFLAGS)


# -----------
# make clean
# (TODO: not yet working)

MODELS = ocean_only ice_ocean_SIS2 coupled_AM2_LM3_SIS2

DEPS = \
  atmos_null land_null icebergs ice_param AM2 LM3

.PHONY: clean
clean: $(foreach m,$(MODELS),clean.$(m)) clean.fms
clean.ocean_only:
	$(MAKE) -C ocean_only/ $(OCEAN_ONLY_BUILDFLAGS) clean
clean.ice_ocean_SIS2:
	$(MAKE) -C ice_ocean_SIS2/ $(ICE_OCEAN_BUILDFLAGS) clean
clean.coupled_AM2_LM3_SIS2:
	$(MAKE) -C coupled_AM2_LM3_SIS2/ $(COUPLED_BUILDFLAGS) clean
clean.fms:
	$(MAKE) -C shared/fms $(FMS_BUILDFLAGS) clean

.PHONY: $(foreach m,$(MODELS) $(DEPS) fms,$(m).clean)

$(foreach model,$(MODELS),$(model).clean):
	$(MAKE) -C $(subst .clean,,$@) clean

$(foreach dep,$(DEPS) fms,$(dep).clean):
	$(MAKE) -C shared/$(subst .clean,,$@) clean
