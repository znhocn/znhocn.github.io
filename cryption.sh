#!/bin/bash

help(){
    echo "Usage:"
    echo "  $0 [en|de]"
    echo "  [en] is Encrypt Source. [de] is Decrypt Source."
}

f_encrypt(){
    for i in source/_posts/*.md; do gpg --batch --yes -ea -r DBE1822F $i; done
    for i in source/_drafts/*.md; do gpg --batch --yes -ea -r DBE1822F $i; done
    echo "Encrypt OK"
}

f_decrypt(){
    for i in source/_posts/*.asc; do gpg --batch --yes $i; done
    for i in source/_drafts/*.asc; do gpg --batch --yes $i; done
    echo "Decrypt OK"
}

case $1 in
en) f_encrypt ;;
de) f_decrypt ;;
*) help ;
esac
