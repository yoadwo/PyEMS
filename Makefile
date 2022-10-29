all:
	python setup.py build_ext --inplace
clean:
	rm -rf build pyems.c pyems.so
