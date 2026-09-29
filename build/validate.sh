#!/bin/bash
# =============================================================================
# Fenstra – Kickstart-Dateien prüfen
# =============================================================================
# 1. ksvalidator mit der Syntaxversion von Fedora 44
# 2. Bash-Syntax der eingebetteten %post-Skripte und aller Skripte in build/
# Aufruf: bash build/validate.sh
# =============================================================================
set -uo pipefail
cd "$(dirname "$0")/.." || exit 1
rc=0
VER="${FENSTRA_KSVERSION:-F44}"

command -v ksvalidator >/dev/null || { echo "ksvalidator fehlt (Paket pykickstart, oder: pip install pykickstart)"; exit 1; }

echo "== ksvalidator ($VER) =="
for f in kickstart/*.ks; do
  if out=$(ksvalidator -v "$VER" "$f" 2>&1); then
    echo "  ok      $f"
  else
    echo "  FEHLER  $f"; echo "$out" | sed 's/^/          /'; rc=1
  fi
done

echo "== Bash-Syntax der %post-Abschnitte =="
tmp=$(mktemp -d)
for f in kickstart/*.ks; do
  awk -v dir="$tmp" -v base="$(basename "$f")" '
    /^%post/ { n++; p=1; file=dir "/" base "." n ".sh"; next }
    /^%end/  { p=0; next }
    p        { print > file }
  ' "$f"
  for s in "$tmp/$(basename "$f")".*.sh; do
    [ -e "$s" ] || continue
    if bash -n "$s" 2>"$tmp/err"; then
      echo "  ok      $f ($(basename "$s" .sh | sed 's/.*\.//'). %post)"
    else
      echo "  FEHLER  $f: $(cat "$tmp/err")"; rc=1
    fi
    # eingebettete Skripte (Heredocs) einzeln prüfen
    awk -v dir="$tmp" '
      /^cat > [^ ]+ << .EOF.$/ { f=$3; gsub("/","_",f); out=dir "/embedded" f; p=1; next }
      /^EOF$/ && p { p=0; close(out); next }
      p { print > out }
    ' "$s"
  done
done
for e in "$tmp"/embedded*; do
  [ -e "$e" ] || continue
  head -1 "$e" | grep -q '^#!/bin/bash' || continue
  if bash -n "$e" 2>"$tmp/err"; then
    echo "  ok      eingebettet: ${e##*/embedded}"
  else
    echo "  FEHLER  eingebettet: ${e##*/embedded}: $(cat "$tmp/err")"; rc=1
  fi
done
rm -rf "$tmp"; tmp=$(mktemp -u)

echo "== Paketquellen (packages/) =="
while IFS= read -r f; do
  if python3 -c "import json,sys; json.load(open(sys.argv[1]))" "$f" 2>"$tmp.err"; then echo "  ok      $f"; else echo "  FEHLER  $f: $(cat "$tmp.err")"; rc=1; fi
done < <(find packages -name '*.json')
while IFS= read -r f; do
  if python3 -c "import xml.dom.minidom,sys; xml.dom.minidom.parse(sys.argv[1])" "$f" 2>"$tmp.err"; then echo "  ok      $f"; else echo "  FEHLER  $f: $(head -1 "$tmp.err")"; rc=1; fi
done < <(find packages -name '*.svg' -o -path '*/fontconfig/*.conf' -o -name '60-selawik.conf')
while IFS= read -r f; do
  if python3 -m py_compile "$f" 2>"$tmp.err"; then echo "  ok      $f"; else echo "  FEHLER  $f: $(cat "$tmp.err")"; rc=1; fi
done < <(find packages -name '*.py')
while IFS= read -r f; do
  head -1 "$f" | grep -q '^#!/bin/bash' || continue
  if bash -n "$f"; then echo "  ok      $f"; else echo "  FEHLER  $f"; rc=1; fi
done < <(find packages -type f -perm -u+x ! -name '*.py')
if command -v rpmspec >/dev/null; then
  for f in packages/*/*.spec; do
    if rpmspec -P "$f" >/dev/null 2>"$tmp.err"; then echo "  ok      $f (rpmspec)"; else echo "  FEHLER  $f: $(head -3 "$tmp.err")"; rc=1; fi
  done
else
  echo "  (rpmspec fehlt, Specs werden nur in WSL geprüft)"
fi
rm -f "$tmp.err"

echo "== Bash-Syntax build/*.sh =="
for s in build/*.sh; do
  if bash -n "$s"; then echo "  ok      $s"; else echo "  FEHLER  $s"; rc=1; fi
done

[ $rc -eq 0 ] && echo "Alles in Ordnung." || echo "Es gibt Fehler."
exit $rc
