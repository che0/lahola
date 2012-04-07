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

function index()
{
	wget \
		--convert-links --max-redirect 0 \
		--reject jpg,JPG,jpeg,JPEG,mp3,MP3,gif,GIF,png,PNG,rtf,RTF,bmp,BMP,mid,MID,rmi,RMI,tit,TIT \
		--directory-prefix ${INDEX_DIR} \
		http://www.henryklahola.nazory.cz/ \
	|| die "can't download"
}

[ "$1" == "--force" ] && FORCE=1

. ${0%/*}/conf/config.sh
cd $REPODIR

curl --head http://www.henryklahola.nazory.cz/ 2>/dev/null | grep ^ETag: > etag.new
etag_changed=$(diff etag etag.new 2>&1 | wc -l)
rm etag.new

if [ ! "$FORCE" -a "$etag_changed" -eq 0 ]
then
	exit 0
fi

refresh
find www.henryklahola.nazory.cz -type f | xargs python nowz.py
[ "$1" = "-r" ] && exit 0

git add www.henryklahola.nazory.cz

diff="$(mktemp)"
echo "automatic update:" > "${diff}"
git diff --cached --no-color --stat >> "${diff}"
git commit --quiet --all --file "${diff}"
rm -f "${diff}"
git push origin master >/dev/null 2>&1 || die "unable to push"
