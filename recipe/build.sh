# Get an updated config.sub and config.guess
set -ex
cp $BUILD_PREFIX/share/gnuconfig/config.* .
mkdir build
cd build

# Manually disable SSE for platforms that don't support it
# in hardware 
# https://github.com/strukturag/libde265/issues/308
EXTRA_FLAGS=
if [[ "${target_platform}" == "osx-arm64" ]]; then
  EXTRA_FLAGS="${EXTRA_FLAGS} -DDISABLE_SSE=ON"
fi

# $BUILD_PREFIX/bin/../x86_64-conda-linux-gnu/bin/ld: libde265/libde265.so.0.1.11: undefined reference to `pthread_create'
#$BUILD_PREFIX/bin/../x86_64-conda-linux-gnu/bin/ld: libde265/libde265.so.0.1.11: undefined reference to `pthread_join'
if [[ "$target_platform" == linux-* ]]
then
  export LDFLAGS="${LDFLAGS} -lpthread"
fi

cmake ${CMAKE_ARGS} -G "Ninja" \
  -DCMAKE_INSTALL_PREFIX="$PREFIX" \
  -DCMAKE_PREFIX_PATH="$PREFIX" \
  -DCMAKE_SYSTEM_PREFIX_PATH="$PREFIX" \
  -DCMAKE_BUILD_TYPE="Release" \
  -DCMAKE_SHARED_LINKER_FLAGS="-lpthread" \
  ${EXTRA_FLAGS} \
  ..

ninja

ninja install
