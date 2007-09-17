#!/bin/sh -e
# For deploying Webconverger images
# hendry@webconverger.org
OUTPUT=~/www

[ $1 ] || exit
DIR=$1
TYPE=`basename $DIR | awk -F - '{print $NF}' | tr / ' '` # gets word after last dash

echo $DIR
echo $TYPE

case $TYPE in
    fullyfree)
    echo Freee
    PUBDIR=$OUTPUT/$TYPE
    break
    ;;
    mini)
    echo Freee
    PUBDIR=$OUTPUT/$TYPE
    break
    ;;
    ru)
    echo Russia
    PUBDIR=$OUTPUT/i18n/$TYPE
    break
    ;;
    jp)
    echo Japan
    PUBDIR=$OUTPUT/i18n/$TYPE
    break
    ;;
    lv)
    echo Latvia
    PUBDIR=$OUTPUT/i18n/$TYPE
    break
    ;;
    fr)
    echo France
    PUBDIR=$OUTPUT/i18n/$TYPE
    break
    ;;
    de)
    echo Germany
    PUBDIR=$OUTPUT/i18n/$TYPE
    break
    ;;
    ko)
    echo Korea/Hannux
    PUBDIR=$OUTPUT/i18n/$TYPE
    break
    ;;
    cn)
    echo China
    PUBDIR=$OUTPUT/i18n/$TYPE
    ;;
    es)
    echo Spanish
    PUBDIR=$OUTPUT/i18n/$TYPE
    ;;
    webconverger)
    echo Default Webconverger
    TYPE="en"
    PUBDIR=$OUTPUT/
    ;;
    tor)
    echo Tor
    PUBDIR=$OUTPUT/$TYPE
    ;;
    opera)
    echo Opera
    PUBDIR=$OUTPUT/$TYPE
    ;;
    *)
    echo Unsupported $TYPE
    exit
    ;;
esac

#[ -d $PUBDIR ] && mv $PUBDIR ~/old # remember to check ~/old
echo $DIR/packages.txt
VERSION=`grep webconverger-base $DIR/binary/packages.txt | awk '{print $3}'`
[ $VERSION ] || exit

mkdir -p $PUBDIR || echo $PUBDIR exists with `ls $PUBDIR`

mv -v $DIR/binary.iso $PUBDIR/webc-$VERSION.$TYPE.iso &&
md5sum $PUBDIR/webc-$VERSION.$TYPE.iso > $PUBDIR/webc-$VERSION.$TYPE.iso.MD5SUM

mv -v $DIR/binary.img $PUBDIR/webc-$VERSION.$TYPE.img
mv -v $DIR/source.tar $PUBDIR/webc-$VERSION.$TYPE.src.tar
cp -v $DIR/binary/packages.txt $PUBDIR/webc-$VERSION.$TYPE.txt # ro
