#!/bin/bash

# ffmpeg installation script for centos 
# __author__ : Mansoor (manz@digitz.org)


function banner {

	echo -en "

+++++++++++++++++++++++++++++++++++++++++
+    FFmpeg Installer for CentOS        +
+++++++++++++++++++++++++++++++++++++++++

Please note that this is for Centos 
Choose an option below: 

    1. Install FFmpeg
    2. Update FFmpeg
    3. Uninstall FFmpeg
    4. Exit and do nothing

    Your Choice : "


}


function install {

	echo "Installing dependencies..!"
	 yum install autoconf automake cmake freetype-devel gcc gcc-c++ git libtool make mercurial nasm pkgconfig zlib-devel -y

	 mkdir ~/ffmpeg_sources

	 #Yasm
	 echo "Installing YASM.."
	 cd ~/ffmpeg_sources
	 git clone --depth 1 git://github.com/yasm/yasm.git
	 cd yasm
	 autoreconf -fiv
	 ./configure --prefix="$HOME/ffmpeg_build" --bindir="$HOME/bin"
	 make
	 make install
	 make distclean

	 #libx264
	 echo "Installing libx264..."
	 cd ~/ffmpeg_sources
	 git clone --depth 1 git://git.videolan.org/x264
	 cd x264
	 PKG_CONFIG_PATH="$HOME/ffmpeg_build/lib/pkgconfig" ./configure --prefix="$HOME/ffmpeg_build" --bindir="$HOME/bin" --enable-static
	 make
	 make install
	 make distclean

	# libx265
	echo "Installing libx265.."
	cd ~/ffmpeg_sources
	hg clone https://bitbucket.org/multicoreware/x265
	cd ~/ffmpeg_sources/x265/build/linux
	cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX="$HOME/ffmpeg_build" -DENABLE_SHARED:bool=off ../../source
	make
	make install

	# libfdk_aac
	# AAC audio encoder.
	echo "Installing libfdk_aac Audio encoder.."
	cd ~/ffmpeg_sources
	git clone --depth 1 git://git.code.sf.net/p/opencore-amr/fdk-aac
	cd fdk-aac
	autoreconf -fiv
	./configure --prefix="$HOME/ffmpeg_build" --disable-shared
	make
	make install
	make distclean

	# libmp3lame
	# MP3 audio encoder.
	echo "Installing libmp3lame MP3 encoder.."
	cd ~/ffmpeg_sources
	curl -L -O http://downloads.sourceforge.net/project/lame/lame/3.99/lame-3.99.5.tar.gz
	tar xzvf lame-3.99.5.tar.gz
	cd lame-3.99.5
	./configure --prefix="$HOME/ffmpeg_build" --bindir="$HOME/bin" --disable-shared --enable-nasm
	make
	make install
	make distclean

	# libopus
	echo "Installing libopus.."
	cd ~/ffmpeg_sources
	git clone git://git.opus-codec.org/opus.git
	cd opus
	autoreconf -fiv
	./configure --prefix="$HOME/ffmpeg_build" --disable-shared
	make
	make install
	make distclean

	# libogg
	# Ogg bitstream library
	echo "Installing Ogg bitstream library.."
	cd ~/ffmpeg_sources
	curl -O http://downloads.xiph.org/releases/ogg/libogg-1.3.2.tar.gz
	tar xzvf libogg-1.3.2.tar.gz
	cd libogg-1.3.2
	./configure --prefix="$HOME/ffmpeg_build" --disable-shared
	make
	make install
	make distclean

	# libvorbis 
	# Vorbis audio encoder
	echo "Installing vorbis audio encoder.."
	cd ~/ffmpeg_sources
	curl -O http://downloads.xiph.org/releases/vorbis/libvorbis-1.3.4.tar.gz
	tar xzvf libvorbis-1.3.4.tar.gz
	cd libvorbis-1.3.4
	LDFLAGS="-L$HOME/ffmeg_build/lib" CPPFLAGS="-I$HOME/ffmpeg_build/include" ./configure --prefix="$HOME/ffmpeg_build" --with-ogg="$HOME/ffmpeg_build" --disable-shared
	make
	make install
	make distclean#mtestxo

	# libvpx 
	# VP8/VP9 video encoder.
	echo "Installing VP8/VP9 video encoder.."
	cd ~/ffmpeg_sources
	git clone --depth 1 https://chromium.googlesource.com/webm/libvpx.git
	cd libvpx
	./configure --prefix="$HOME/ffmpeg_build" --disable-examples
	make
	make install
	make clean

	# FFmpeg
	echo "Finally, installing FFmpeg.."
	cd ~/ffmpeg_sources
	git clone http://source.ffmpeg.org/git/ffmpeg.git
	cd ffmpeg
	PKG_CONFIG_PATH="$HOME/ffmpeg_build/lib/pkgconfig" ./configure --prefix="$HOME/ffmpeg_build" --extra-cflags="-I$HOME/ffmpeg_build/include" --extra-ldflags="-L$HOME/ffmpeg_build/lib" --bindir="$HOME/bin" --pkg-config-flags="--static" --enable-gpl --enable-nonfree --enable-libfdk-aac --enable-libfreetype --enable-libmp3lame --enable-libopus --enable-libvorbis --enable-libvpx --enable-libx264 --enable-libx265
	make
	make install
	make distclean
	hash -r
}

function update {

	echo "Updating FFmpeg..!!"
	rm -rf ~/ffmpeg_build ~/bin/{ffmpeg,ffprobe,ffserver,lame,vsyasm,x264,x265,yasm,ytasm}
	yum install autoconf automake cmake gcc gcc-c++ git libtool make mercurial nasm pkgconfig zlib-devel -y

	# Update Yasm 
	echo "Updating YASM..!"
	cd ~/ffmpeg_sources/yasm
	make distclean
	git pull
	./configure --prefix="$HOME/ffmpeg_build" --bindir="$HOME/bin"
	make
	make install


	# Update x264
	echo "Updating x264.."
	cd ~/ffmpeg_sources/x264
	make distclean
	git pull
	PKG_CONFIG_PATH="$HOME/ffmpeg_build/lib/pkgconfig" ./configure --prefix="$HOME/ffmpeg_build" --bindir="$HOME/bin" --enable-static
	make
	make install


	# Update x265
	echo "Updating x265.."
	cd ~/ffmpeg_sources/x265
	rm -rf ~/ffmpeg_sources/x265/build/linux/*
	hg update
	cd ~/ffmpeg_sources/x265/build/linux
	cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX="$HOME/ffmpeg_build" -DENABLE_SHARED:bool=off ../../source
	make
	make install

	# Update libfdk_aac
	echo "Updating libfdk_aac.."
	cd ~/ffmpeg_sources/fdk_aac
	make distclean
	git pull
	./configure --prefix="$HOME/ffmpeg_build" --disable-shared
	make
	make install

	# Update libvpx
	echo "Updating libvpx..!"
	cd ~/ffmpeg_sources/libvpx
	make clean
	git pull
	./configure --prefix="$HOME/ffmpeg_build" --disable-examples
	make
	make install

	# Update FFmpeg
	echo "Finally, updating FFmpeg..!!"
	cd ~/ffmpeg_sources/ffmpeg
	make distclean
	git pull

	PKG_CONFIG_PATH="$HOME/ffmpeg_build/lib/pkgconfig" ./configure --prefix="$HOME/ffmpeg_build" --extra-cflags="-I$HOME/ffmpeg_build/include" --extra-ldflags="-L$HOME/ffmpeg_build/lib" --bindir="$HOME/bin" --pkg-config-flags="--static" --enable-gpl --enable-nonfree --enable-libfdk-aac --enable-libfreetype --enable-libmp3lame --enable-libopus --enable-libvorbis --enable-libvpx --enable-libx264 --enable-libx265
	make
	make install

}

function uninstall {
	echo "Removing FFmpeg..!!"
	rm -rf ~/ffmpeg_build ~/ffmpeg_sources ~/bin/{ffmpeg,ffprobe,ffserver,lame,vsyasm,x264,yasm,ytasm}
	yum erase autoconf automake cmake gcc gcc-c++ git libtool mercurial nasm pkgconfig zlib-devel
	hash -r
}

function main {

	banner
	read choice
	if [[ $choice -eq 1 ]]; then

		echo "Are you sure you want to install FFmpeg?"
		echo "Press Enter to continue. Ctrl+C to exit"
		read
		install

	elif [[ $choice -eq 2 ]]; then

		echo "Are you sure you want to update FFmpeg?"
		echo "Press Enter to continue. Ctrl+C to exit"
		read
		update

	elif [[ $choice -eq 3 ]]; then
		
		echo "Are you sure you want to remove FFmpeg?"
		echo "Press Enter to continue. Ctrl+C to exit"
		read
		uninstall

	elif [[ $choice -eq 4 ]]; then

		echo "Chose to exit..!"
		exit

	else
		echo "Invalid option. "
		exit
	fi
}

main