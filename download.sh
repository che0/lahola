#!/bin/bash

function die()
{
	echo "$*" >&2
	exit 1
}

function refresh()
{
	rm -fr www.henryklahola.nazory.cz
	wget \
		--output-file $REPODIR/wget.log \
		--recursive --level 64 --convert-links --max-redirect 0 \
		--reject jpg,JPG,jpeg,JPEG,mp3,MP3,gif,GIF,png,PNG,rtf,RTF,bmp,BMP,mid,MID,rmi,RMI,tit,TIT \
		http://www.henryklahola.nazory.cz/ \
	|| die "can't download"
}

. ${0%/*}/conf/config.sh
cd $REPODIR

refresh
find www.henryklahola.nazory.cz -type f | xargs python nowz.py
[ "$1" = "-r" ] && exit 0

git add www.henryklahola.nazory.cz

diff="$(mktemp)"
echo "automatic update:" > "${diff}"
git diff --no-color --stat >> "${diff}"
git commit --quiet --all --file "${diff}"
rm -f "${diff}"
git push origin master >/dev/null 2>&1 || die "unable to push"
