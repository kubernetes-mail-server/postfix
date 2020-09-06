#!/usr/bin/env bash

[ -z "$(command -v travis)" ] && echo "You must install the travis cli tool first" && exit 1
[ -z "$(command -v awk)" ] && echo "The awk tool is not available, can't proceed, you will have to do it yourself manually" && exit 1

cat $HOME/.kube/config >> kubeconfig
echo "kubeconfig" >> .gitignore
GIT_IGNORE=$(awk '!a[$0]++' .gitignore)
echo "$GIT_IGNORE" > .gitignore
travis encrypt-file kubeconfig