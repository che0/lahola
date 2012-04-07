#!/usr/bin/env python

import sys, re

WZ_RE = re.compile(r'<!--WZ-REKLAMA-1.0IZ-->.*<!--WZ-REKLAMA-1.0IK-->|<!--wz-lista-[^>]+--><script[^\n]*</script>', re.DOTALL)

def cleanup(filename):
	f = open(filename, 'rb')
	content = f.read()
	f.close()
	content = WZ_RE.sub('<!--WZ-REKLAMA-->', content)
	f = open(filename, 'wb')
	f.write(content)
	f.close()

if __name__ == '__main__':
	for filename in sys.argv[1:]:
		cleanup(filename)
