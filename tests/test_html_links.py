"""Check deployed-prefix resolution without overlooking absent files or anchors."""
import json
from pathlib import Path
import subprocess
import tempfile
import unittest

SCRIPT = Path(__file__).resolve().parents[1] / 'scripts/check-html-links.py'

class DeploymentLinks(unittest.TestCase):
    def test_prefix_and_real_missing_targets(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            (root/'index.html').write_text('<h1 id="home">Home</h1>')
            (root/'404.html').write_text('<a href="/equilibria/#home">Home</a>')
            command = ['python3', str(SCRIPT), str(root), str(root/'result.json'),
                       '--base-path', '/equilibria/']
            result = subprocess.run(command, capture_output=True)
            self.assertEqual(result.returncode, 0, result.stdout)
            (root/'404.html').write_text('<a href="/equilibria/#absent">Absent</a>'
                                        '<img src="/equilibria/absent.png">')
            result = subprocess.run(command, capture_output=True)
            self.assertEqual(result.returncode, 1)
            errors = json.loads((root/'result.json').read_text())['broken']
            self.assertEqual({x[2] for x in errors}, {'missing file', 'missing anchor'})

if __name__ == '__main__':
    unittest.main()
