CXX:=/home/zhangfuwen/bin/sdk-tools-linux-3859397/ndk-bundle/toolchains/llvm/prebuilt/linux-x86_64/bin/aarch64-linux-android28-clang++

mychroot: mychroot.cpp
	${CXX} ./mychroot.cpp -static-libstdc++ -o mychroot

netns_demo: netns_demo.cpp
	${CXX} ./netns_demo.cpp -static-libstdc++ -o netns_demo
userns_demo: userns_demo.cpp
	${CXX} ./userns_demo.cpp -static-libstdc++ -lcap -o userns_demo

