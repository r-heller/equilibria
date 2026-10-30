import assert from 'node:assert/strict';
import {readFile} from 'node:fs/promises';
const source=await readFile(new URL('../assets/js/overview/search.js',import.meta.url),'utf8');
const {normaliseUrl}=await import('data:text/javascript;base64,'+Buffer.from(source).toString('base64'));
for(const url of [
 'tutorials/foundations/nash/',
 '/tutorials/foundations/nash/index.html',
 '/equilibria/tutorials/foundations/nash/',
 'https://example.test/equilibria/tutorials/foundations/nash/index.html?q=term#section',
 '/tutorials/foundations/nash.html',
]) assert.equal(normaliseUrl(url),'foundations/nash');
assert.notEqual(normaliseUrl('/tutorials/foundations/nash/'),normaliseUrl('/tutorials/foundations/nash-bargaining/'));
console.log('Directory, HTML, deployment-prefix and absolute search URLs identify the same tutorial');
