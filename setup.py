from distutils.core import setup
from distutils.extension import Extension
from Pyrex.Distutils import build_ext

setup(
    name = "pyems", 
    version = "0.1",
    ext_modules=[ 
        Extension("pyems", ["pyems.pyx"], 
                  extra_compile_args = ["-I/opt/tibco/ems/clients/c/include"],
                  #libraries = ["tibems", "ws2_32"])
		  library_dirs = ["/opt/tibco/ems/clients/c/lib"],
                  libraries = ["tibems", "ssl", "crypto", "z"])
    ],
    cmdclass = {'build_ext': build_ext}
)
