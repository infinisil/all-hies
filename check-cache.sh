#!/usr/bin/env bash

# This script is here for both future reference on how to check that a cache
# serves a path, and to make sure cachix's 10GB limit doesn't mean it deletes
# paths still needed.

# In addition, you could use these paths here to fetch the derivations directly,
# completely circumventing the slow Nix evaluation, at the cost of
# reproducibility. Only seems useful for one-off testing or so.

storepaths=(
  # 0.14.0.0
  ## x86_64-linux
  /nix/store/fv5g10aimim5dpiczm2lfihaag02vhxl-haskell-ide-engine-ghc842-0.14.0.0
  /nix/store/jsqg0bzzwwhhvdmqmp7i4w8lgb3m16d4-haskell-ide-engine-ghc843-0.14.0.0
  /nix/store/k6xpscrdj6mljxs0lfc7z53h02d2pssy-haskell-ide-engine-ghc844-0.14.0.0
  /nix/store/ghkyvmv9hii7j0mxrhw65k1rf8714zjv-haskell-ide-engine-ghc861-0.14.0.0
  /nix/store/6jdnw7nmh70qdn68pkxribbqfx3hgb29-haskell-ide-engine-ghc862-0.14.0.0
  /nix/store/yfdwlzwvgz9mw6ahyfi9kzy73bfw28wg-haskell-ide-engine-ghc863-0.14.0.0
  /nix/store/k719sij8skn4r8l128hqg324gpw13bsv-haskell-ide-engine-ghc864-0.14.0.0
  /nix/store/6wsy89l4jnsy4qp4ywsyg572ily295zl-haskell-ide-engine-ghc865-0.14.0.0
  ## x86_64-darwin
  /nix/store/96swblwrifddpri0pphq60l3wmw5glx3-haskell-ide-engine-ghc842-0.14.0.0
  /nix/store/vjn9z839m1qgs1hx25w1m19mqarcrga6-haskell-ide-engine-ghc843-0.14.0.0
  /nix/store/1ynzvm8a5ah0yaanjyycxgxsi8ha6fm8-haskell-ide-engine-ghc844-0.14.0.0
  /nix/store/ywiqwi0zk8f90xfngn2fy5v0j8mcg4k7-haskell-ide-engine-ghc861-0.14.0.0
  /nix/store/k5bl1k6sxqzllxaq91y12k7issyx352n-haskell-ide-engine-ghc862-0.14.0.0
  /nix/store/m2r5avlqd8jqwhadgnxh3mx9144c85sc-haskell-ide-engine-ghc863-0.14.0.0
  /nix/store/kx888gg01y3j2r5ydfzqadb0v3mv1vyf-haskell-ide-engine-ghc864-0.14.0.0
  /nix/store/6l9ciqyf5hrw7jrskwvfy60jayklrwdr-haskell-ide-engine-ghc865-0.14.0.0

  # 0.13.0.0
  ## x86_64-linux
  /nix/store/7xcbnma9w0678wjy8mqzmx8vr06ywr1q-haskell-ide-engine-ghc822-0.13.0.0
  /nix/store/qqcjlnl0qcs06vk691nz9mq38kwb1b0m-haskell-ide-engine-ghc842-0.13.0.0
  /nix/store/1bsinl1ipd4xd9a28mm870b585pr695j-haskell-ide-engine-ghc843-0.13.0.0
  /nix/store/nrjf5k71rc7gbm24nzz3pm8dlhi9ffgj-haskell-ide-engine-ghc844-0.13.0.0
  /nix/store/0fmpy958r9zzc9yarhjyq4j9sql4igh3-haskell-ide-engine-ghc861-0.13.0.0
  /nix/store/72iwb479zlf1wir2zhy47w7j6ba24x8a-haskell-ide-engine-ghc862-0.13.0.0
  /nix/store/wimhij1snfmz9bjjblspg6l3zjfbkpn1-haskell-ide-engine-ghc863-0.13.0.0
  /nix/store/b54jxmrzs5y4mir3n5wz5n4xgvz6jzd3-haskell-ide-engine-ghc864-0.13.0.0
  /nix/store/zz008pivvzzkmbwczax59kx9ik1vfcxh-haskell-ide-engine-ghc865-0.13.0.0
  ## x86_64-darwin
  /nix/store/dwnjj266g3m2xyxxyjqj97r02bsmy1kw-haskell-ide-engine-ghc822-0.13.0.0
  /nix/store/kpzxvzljbrpk8jk8kjc5am6vkvyp7sfr-haskell-ide-engine-ghc842-0.13.0.0
  /nix/store/nvk48cyynyi482ihfhf6xi7nah3w0skl-haskell-ide-engine-ghc843-0.13.0.0
  /nix/store/n1xy8781mlidx9wdn95sb7mic025n05y-haskell-ide-engine-ghc844-0.13.0.0
  /nix/store/rksnq99m26ydi890jxgi2jh65b5ygvay-haskell-ide-engine-ghc861-0.13.0.0
  /nix/store/y9bp4bpv2bp4m7cfv386c8kcfwx2qxmv-haskell-ide-engine-ghc862-0.13.0.0
  /nix/store/03ixnk46zlvbvgagf7fnmwrra0351a6m-haskell-ide-engine-ghc863-0.13.0.0
  /nix/store/596vx7bif80rkz633mg2zn91k0szrr60-haskell-ide-engine-ghc864-0.13.0.0
  /nix/store/fnx9bhik3vrdxdfzqap9l4aph0a2cljc-haskell-ide-engine-ghc865-0.13.0.0

  # 0.12.0.0
  ## x86_64-linux
  /nix/store/vm2g0gka3wc9m2766s9f8xzrlliby5yi-haskell-ide-engine-ghc822-0.12.0.0
  /nix/store/17ypzfshwxqb638bhxfbk6f6xzanzzsz-haskell-ide-engine-ghc842-0.12.0.0
  /nix/store/6r4jbflxzx31n3bfy25blmy5prg0x1xr-haskell-ide-engine-ghc843-0.12.0.0
  /nix/store/5ma13xjx2pvr97w1fmkz1hjy1pr0vzv7-haskell-ide-engine-ghc844-0.12.0.0
  /nix/store/hqzbnrhagm1m0zkss5jf3sndfzipjk01-haskell-ide-engine-ghc861-0.12.0.0
  /nix/store/6mdd6caab3qlnhbjr3c7jxki4dwkab9q-haskell-ide-engine-ghc862-0.12.0.0
  /nix/store/55izx4ic9jh22pp2h75gsy75fwfnxl5c-haskell-ide-engine-ghc863-0.12.0.0
  /nix/store/df49pvrydr12i8mk4l98vdhfvd0grbak-haskell-ide-engine-ghc864-0.12.0.0
  /nix/store/qfpgpi3mcw8w0m6vdfn77bli5pdw8c1d-haskell-ide-engine-ghc865-0.12.0.0
  ## x86_64-darwin
  /nix/store/2srmzjnzy2sjlrcd18mmmbjjlpmdwvjz-haskell-ide-engine-ghc822-0.12.0.0
  /nix/store/58z40kd2wpqcm0i0npjbhy0rmy5x7xx2-haskell-ide-engine-ghc842-0.12.0.0
  /nix/store/znlx4pq3gy4aish8bkm48pdix6a246y1-haskell-ide-engine-ghc843-0.12.0.0
  /nix/store/zp8k0ili5k7amn3rl6rvsxsi6spcyqkc-haskell-ide-engine-ghc844-0.12.0.0
  /nix/store/6kwk290gcvqydq5hlb4z1d79v9p1pzb2-haskell-ide-engine-ghc861-0.12.0.0
  /nix/store/i3jwdmq0wyymsnbp7abwjxmy5kmyjjd5-haskell-ide-engine-ghc862-0.12.0.0
  /nix/store/zhc4kvmcblsssflfiyr9f7p98prs38s4-haskell-ide-engine-ghc863-0.12.0.0
  /nix/store/pshm49bih77bmnmyqhvav90vbbhiqan2-haskell-ide-engine-ghc864-0.12.0.0
  /nix/store/n1dg6asggdi4v0k49pnwvfvzqazxcszc-haskell-ide-engine-ghc865-0.12.0.0

  # 0.11.0.0
  ## x86_64-linux
  /nix/store/bi1c5s6ql98hwbfnyr1hf5vy5g4qkyv9-haskell-ide-engine-ghc822-0.11.0.0
  /nix/store/6yfa5vh4x3nc6a6skmsw311fbdr2sbgs-haskell-ide-engine-ghc842-0.11.0.0
  /nix/store/4q1077xr3pxv218a61vzlk82g6mxaihd-haskell-ide-engine-ghc843-0.11.0.0
  /nix/store/kvb4vqnbdh8gpj3y75ysixzwf165qib3-haskell-ide-engine-ghc844-0.11.0.0
  /nix/store/fkrvvxxsqqyipj3832vfff75pv4ms5bd-haskell-ide-engine-ghc861-0.11.0.0
  /nix/store/nacxmfd764v9g82gc345j1rapn2rhjnz-haskell-ide-engine-ghc862-0.11.0.0
  /nix/store/q1pbpprnsqs1frjnlsjfzjvv4bi08vzj-haskell-ide-engine-ghc863-0.11.0.0
  /nix/store/gw6pp5m05nvg7gshakaj4gcpq1fvg2w0-haskell-ide-engine-ghc864-0.11.0.0
  /nix/store/h7hgxf86zfgh1dxv6jlybzlp96590q9j-haskell-ide-engine-ghc865-0.11.0.0
  # x86_64-darwin
  /nix/store/fqscw5v1fpza5wzw4fiw8810vy2581xg-haskell-ide-engine-ghc822-0.11.0.0
  /nix/store/2r41givhaabpsrlf4djsbfb90p7nc63v-haskell-ide-engine-ghc842-0.11.0.0
  /nix/store/fzkwrlvagpxss3b2xnbvmijmzl32xy8g-haskell-ide-engine-ghc843-0.11.0.0
  /nix/store/cs29ppwf6q92lj5pwzz6989mq6g3smpv-haskell-ide-engine-ghc844-0.11.0.0
  /nix/store/zqypv7cdjsm8wip289zg8x2c69df2svr-haskell-ide-engine-ghc861-0.11.0.0
  /nix/store/ph1npnw2301xgi1v8cf660q7fx048w10-haskell-ide-engine-ghc862-0.11.0.0
  /nix/store/zsmrfr9s9h8hkkwkiinpn81khip2zpdp-haskell-ide-engine-ghc863-0.11.0.0
  /nix/store/10zbnxkfzxx5aza2b9yf1pdbj74lj44k-haskell-ide-engine-ghc864-0.11.0.0
  /nix/store/s3mx14v0is47w6s1f59qds3cajzs1z1i-haskell-ide-engine-ghc865-0.11.0.0

  # 0.10.0.0
  ## x86_64-linux
  /nix/store/bqn4lhr3sy7l0js8i48cn8asdxch0fyg-haskell-ide-engine-ghc822-0.10.0.0
  /nix/store/1zk8ak6xbj80xb1cwpfhvgfsqr6qc5nb-haskell-ide-engine-ghc842-0.10.0.0
  /nix/store/xixdvl0zaxwxv7vg5yh5n1c3mfziylmy-haskell-ide-engine-ghc843-0.10.0.0
  /nix/store/2vkknszx8a79zli4r7m1km0g5q839ljy-haskell-ide-engine-ghc844-0.10.0.0
  /nix/store/5byn4lv9vs4sx8wbj4in33i6mrlhp10k-haskell-ide-engine-ghc861-0.10.0.0
  /nix/store/624qszlz61jvmdr1nvmz7kf2akdjrn3d-haskell-ide-engine-ghc862-0.10.0.0
  /nix/store/ix0cl548sg5kv5dw8baq429javdy2hb3-haskell-ide-engine-ghc863-0.10.0.0
  /nix/store/w5xzzmmdm1kdfm195cq4blzv5dl69z6f-haskell-ide-engine-ghc864-0.10.0.0
  /nix/store/aqb38lri5cw7bv1g8bh6md2z5kn3yq4f-haskell-ide-engine-ghc865-0.10.0.0
  ## x86_64-darwin
  /nix/store/zg0swixk3v280xr3bxvly9csrf353xc8-haskell-ide-engine-ghc822-0.10.0.0
  /nix/store/rxyizclnkfz7v5wmcffhppkfwbgxs8w2-haskell-ide-engine-ghc842-0.10.0.0
  /nix/store/3hbzcabibrc67zjy6fxipzs9wbs6y164-haskell-ide-engine-ghc843-0.10.0.0
  /nix/store/90z9h7ij4yhqi7bgr3jac4lnx70g6w1j-haskell-ide-engine-ghc844-0.10.0.0
  /nix/store/0035fzz1923ybdq4wq9dqslv4mgxxxlb-haskell-ide-engine-ghc861-0.10.0.0
  /nix/store/r529lppz0hcm0jf2qw5gb788d1piifhf-haskell-ide-engine-ghc862-0.10.0.0
  /nix/store/939ipf6rw9hdq7j8zp31n3m0q97y462z-haskell-ide-engine-ghc863-0.10.0.0
  /nix/store/sd86wdkix55i6zri12rl6inwbpsr1nmy-haskell-ide-engine-ghc864-0.10.0.0
  /nix/store/cjkd4zxwg4p4zf1hps6hna47diddjd2b-haskell-ide-engine-ghc865-0.10.0.0

  # 0.9.0.0
  ## x86_64-linux
  /nix/store/826simd2sxai2ixp79sagig45fcqlbzx-haskell-ide-engine-ghc821-0.9.0.0
  /nix/store/4l7cmyd7yz7f7fh9c7ncxp7a0ibkiyhk-haskell-ide-engine-ghc822-0.9.0.0
  /nix/store/pfs0zmr1gj8m83cj811dxpqi38rngaby-haskell-ide-engine-ghc842-0.9.0.0
  /nix/store/xbg2gz5h5grgksdj11fa5bn4g76pa205-haskell-ide-engine-ghc843-0.9.0.0
  /nix/store/hpip464r63fgbm13gc2rvw4dgy5wx7jq-haskell-ide-engine-ghc844-0.9.0.0
  /nix/store/93gs7s6fvvzjq5s65grm7ajnchc104mq-haskell-ide-engine-ghc861-0.9.0.0
  /nix/store/fm6q1p4qahvpzwpzywhpmgpwdlqmalf5-haskell-ide-engine-ghc862-0.9.0.0
  /nix/store/718j08f3sfrcznmg4jm468wi52ki8da9-haskell-ide-engine-ghc863-0.9.0.0
  /nix/store/ykfwddgjmg8vaf7i83lbfpzmlc6ga0d0-haskell-ide-engine-ghc864-0.9.0.0
  ## x86_64-darwin
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
