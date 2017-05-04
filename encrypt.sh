#!/bin/bash

for i in source/_posts/*.md; do gpg --batch --yes -ea -r DBE1822F $i; done
