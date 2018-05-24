.SUFFIXES:

.PHONY: install build clean clobber

RUSTFLAGS ?= "-C target-cpu=native"
CARGO_BUILD ?= cargo +nightly build --release --features 'simd-accel'

bin = rg
dist_bin = dist/$(bin)
build_bin = target/release/$(bin)

install: build
	cd dist && $(MAKE) install

build: $(dist_bin)

$(dist_bin): $(build_bin)
	$(shell . ci/utils.sh && make_dist)

$(build_bin):
	RUSTFLAGS=$(RUSTFLAGS) $(CARGO_BUILD)

clean:
	$(RM) -r dist

clobber: clean
	cargo clean
