all: opa_storage.exe

opa_storage.exe: src/main.opa
	opa src/main.opa -o opa_storage.exe

clean:
	\rm -Rf *.exe _build _tracks *.log
