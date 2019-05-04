#!/usr/bin/env bash

# This script is here for both future reference on how to check that a cache
# serves a path, and to make sure cachix's 10GB limit doesn't mean it deletes
# paths still needed.

# In addition, you could use these paths here to fetch the derivations directly,
# completely circumventing the slow Nix evaluation, at the cost of
# reproducibility. Only seems useful for one-off testing or so.

storepaths=(
	# x86_64-linux
	/nix/store/826simd2sxai2ixp79sagig45fcqlbzx-haskell-ide-engine-ghc821-0.9.0.0
	/nix/store/4l7cmyd7yz7f7fh9c7ncxp7a0ibkiyhk-haskell-ide-engine-ghc822-0.9.0.0
	/nix/store/pfs0zmr1gj8m83cj811dxpqi38rngaby-haskell-ide-engine-ghc842-0.9.0.0
	/nix/store/xbg2gz5h5grgksdj11fa5bn4g76pa205-haskell-ide-engine-ghc843-0.9.0.0
	/nix/store/hpip464r63fgbm13gc2rvw4dgy5wx7jq-haskell-ide-engine-ghc844-0.9.0.0
	/nix/store/93gs7s6fvvzjq5s65grm7ajnchc104mq-haskell-ide-engine-ghc861-0.9.0.0
	/nix/store/fm6q1p4qahvpzwpzywhpmgpwdlqmalf5-haskell-ide-engine-ghc862-0.9.0.0
	/nix/store/718j08f3sfrcznmg4jm468wi52ki8da9-haskell-ide-engine-ghc863-0.9.0.0
	/nix/store/ykfwddgjmg8vaf7i83lbfpzmlc6ga0d0-haskell-ide-engine-ghc864-0.9.0.0

	# x86_64-darwin
	/nix/store/zjg7w8drvgajwg45kcwsrcgbfbyggjda-haskell-ide-engine-ghc821-0.9.0.0
	/nix/store/9wds6q9cwl001z4ygdr2hh70y1db30j6-haskell-ide-engine-ghc822-0.9.0.0
	/nix/store/srbrsjasysqvmva9sjzi5msf56jb9jih-haskell-ide-engine-ghc842-0.9.0.0
	/nix/store/ijks8qwcpdnh4g8r09iz1jhlcviavnba-haskell-ide-engine-ghc843-0.9.0.0
	/nix/store/js2qmcbkvc4nbjzj831lh3l8xb2rrlfv-haskell-ide-engine-ghc844-0.9.0.0
	/nix/store/knmzrcwglv38h83awjczfxvr260i0mvz-haskell-ide-engine-ghc861-0.9.0.0
	/nix/store/k0w4r4x6hghm4rniwpc00jv0w6grf44d-haskell-ide-engine-ghc862-0.9.0.0
	/nix/store/h9q4ikqjwj2wzjgbhcxh8qkmlcd764kj-haskell-ide-engine-ghc863-0.9.0.0
	/nix/store/5lwkwpgd9mdbrj2k267kjjslc5jmp2f4-haskell-ide-engine-ghc864-0.9.0.0
)

for path in ${storepaths[*]}; do
  url=$(sed -r <<< $path \
		-e 's|-.*|.narinfo|' \
		-e 's|/nix/store|https://all-hies.cachix.org|')
	curl -s -o /dev/null -w "$path -> %{http_code}\n" "$url" &
done

wait
