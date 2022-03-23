SKIPUNZIP=1

# Extract files
ui_print "- Extracting module files"
unzip -o "$ZIPFILE" module.prop -d $MODPATH >&2

# paths
original_files=`grep -lr 'security.wsm' /system/vendor/etc/vintf`
replace_path="$MODPATH/system/vendor/etc/vintf"

ui_print "- Start patching..."
mkdir -p $replace_path
for i in $original_files; do
  patched_files="$MODPATH$i"
  cp -f -p $i $replace_path
  set_perm_recursive $replace_path 0 0 0755 0755
  if `sed -i '/<.*security.wsm.*/,/<hal format="hidl">/d' $patched_files` ; then
    ui_print "- Successfully patched $i!"
  else
    ui_print "- Not found security.wsm in xml, Aborting..."
    rm -rf $MODPATH
    abort
  fi
done