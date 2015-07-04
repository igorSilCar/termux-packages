TERMUX_PKG_HOMEPAGE=http://invisible-island.net/ncurses/
TERMUX_PKG_DESCRIPTION="Library for text-based user interfaces in a terminal-independent manner"
_MAJOR_VERSION=5.9
# This is the patch number used for fetching a patch from ftp://invisible-island.net/ncurses/5.9/
# in termux_step_post_extract_package below:
_MINOR_VERSION=20141206
TERMUX_PKG_VERSION=${_MAJOR_VERSION}.${_MINOR_VERSION}
TERMUX_PKG_SRCURL=http://ftp.gnu.org/pub/gnu/ncurses/ncurses-${_MAJOR_VERSION}.tar.gz
# --without-normal disables static libraries:
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="--enable-overwrite --enable-const --without-cxx-binding --without-normal --without-static --with-shared --without-debug --enable-widec --enable-ext-colors --enable-ext-mouse --enable-pc-files --with-pkg-config-libdir=$PKG_CONFIG_LIBDIR --without-ada --without-tests --mandir=$TERMUX_PREFIX/share/man ac_cv_header_locale_h=no"
TERMUX_PKG_RM_AFTER_INSTALL="bin/ncursesw6-config share/man/man1/ncursesw6-config.1 bin/infotocap share/man/man1/infotocap.1m bin/captoinfo share/man/man1/captoinfo.1m"

termux_step_post_extract_package () {
	cd $TERMUX_PKG_SRCDIR
	_PATCH_FILENAME=ncurses-${_MAJOR_VERSION}-${_MINOR_VERSION}-patch.sh
	_PATCHFILE=$TERMUX_PKG_CACHEDIR/$_PATCH_FILENAME
	test ! -f $_PATCHFILE && curl "ftp://invisible-island.net/ncurses/${_MAJOR_VERSION}/${_PATCH_FILENAME}.bz2" | bunzip2 - > $_PATCHFILE
	sh $_PATCHFILE
}

termux_step_post_make_install () {
	cd $TERMUX_PREFIX/lib
	for lib in form menu ncurses panel; do
		for file in lib${lib}w.so*; do 
			ln -s -f $file `echo $file | sed 's/w//'`
		done
		(cd pkgconfig && ln -s -f ${lib}w.pc `echo $lib | sed 's/w//'`.pc)
	done

	if [ `uname` = Darwin ]; then
		cd $TERMUX_PREFIX/share/terminfo
		for l in *; do 
			if [ ${#l} -eq 2 ]; then
				char=`echo 0x$l | awk '{printf "%c\n", $1}'`
				rm -Rf $char
				mv $l $char
			fi
		done
		cd -
	fi
}