SKIPUNZIP=1

# Extract files
ui_print "- Extracting module files"
unzip -o "$ZIPFILE" module.prop -d $MODPATH >&2

# paths
original_files=`grep -lr 'security.wsm' /system/vendor/etc/vintf`

ui_print "- Start patching..."
mkdir -p $replace_path
for i in $original_files; do
  original_file_basename="$(basename "$i")"
  original_file_path="${i%/$original_file_basename*}"
  patched_file="$MODPATH$i"
  replace_path="$MODPATH$original_file_path"
  mkdir -p $MODPATH/$original_file_path
  cp -aR $i $MODPATH/$original_file_path
  set_perm_recursive $replace_path 0 0 0755 0755
  if `sed -i "$(($(awk '/security.wsm/ {print FNR}' $patched_file) - 1)),/<\/hal>/d" $patched_file` ; then
    ui_print "- Successfully patched $i!"
  else
    ui_print "- Failed to patch security.wsm in $i, Aborting..."
    rm -rf $MODPATH
    abort
  fi
done
