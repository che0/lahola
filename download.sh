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
		--no-verbose --output-file $REPODIR/wget.log \
		--recursive --level 64 --convert-links --max-redirect 0 \
		--reject jpg,JPG,jpeg,JPEG,mp3,MP3,gif,GIF,png,PNG,rtf,RTF,bmp,BMP,mid,MID,rmi,RMI,tit,TIT \
		http://www.henryklahola.nazory.cz/ \
	|| die "can't download"
}

. conf/config.sh
cd $REPODIR

refresh
sed -ri 's/^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2} //' wget.log
git add wget.log www.henryklahola.nazory.cz
git commit --quiet --all --message 'automatic update'
git push origin master >/dev/null 2>&1 || die "unable to push"
