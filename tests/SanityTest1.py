#!/usr/bin/python
from avocado import main
from avocado.core import exceptions
from moduleframework import module_framework
import urllib
import os


class SanityTest1(module_framework.AvocadoTest):
    """
    :avocado: enable
    """

    def test1(self):
        self.start()
        conn = urllib.urlopen("http://localhost:" + str(self.getConfig()['service']['port']))
        code = conn.getcode()
        print ">>> Testing fedora.org as a backend"
        print ">>> Returned code: " + str(code)
        print conn.read()
        assert code == 200      

if __name__ == '__main__':
    main()
