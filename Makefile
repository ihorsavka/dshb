INSTALL_DIR     = /usr/local/bin
MANPAGE_DIR     = /usr/local/share/man/man1
XCODE_CONFIG    = Release
DSHB_VERSION    = 0.0.4
ARCHIVE_FOLDER  = archive
ARCHIVE_NAME    = dshb-${DSHB_VERSION}
SUBMODULES_PATH = libs
SUBMODULES      = `find ${SUBMODULES_PATH} -type d -depth 1 | \
                   sed 's/${SUBMODULES_PATH}//' | tr -d '/'`
REPO_URL        = https://github.com/beltex/dshb.git

.PHONY: install machine release debug build uninstall archive archive-remote \
        ronn clean distclean

install: machine release
	cp bin/dshb ${INSTALL_DIR}
	cp doc/dshb.1 ${MANPAGE_DIR}
	du -sh ${INSTALL_DIR}/dshb
machine:
	@sysctl hw.model
	@sw_vers
	@uname -v
	@ioreg -lbrc AppleSMC | grep smc-version | tr -d "|" | xargs
	@xcodebuild -version
	@swiftc -v
release: build
	strip bin/dshb
debug: XCODE_CONFIG=Debug
debug: build
build: libs/SMCKit/README.md
	xcodebuild -configuration ${XCODE_CONFIG} build
	mkdir -p bin
	cp build/${XCODE_CONFIG}/dshb bin
libs/SMCKit/README.md:
	git submodule update --init
uninstall:
	rm ${INSTALL_DIR}/dshb
	rm ${MANPAGE_DIR}/dshb.1
ronn:
	ronn --style=toc doc/dshb.1.ronn
archive:
	@rm -rf ${ARCHIVE_FOLDER}/*;                                       \
	 mkdir -p ${ARCHIVE_FOLDER};                                       \
	 git archive --format zip -o ${ARCHIVE_FOLDER}/tmp HEAD;           \
	 unzip -d ${ARCHIVE_FOLDER}/${ARCHIVE_NAME} ${ARCHIVE_FOLDER}/tmp; \
	 for submodule in ${SUBMODULES}; do                                \
	   cd ${SUBMODULES_PATH}/$$submodule;                              \
	   git archive -o ../../${ARCHIVE_FOLDER}/$$submodule.zip HEAD;    \
	   cd ../../${ARCHIVE_FOLDER};                                     \
	   unzip -d ${ARCHIVE_NAME}/${SUBMODULES_PATH}/$$submodule         \
	                                                  $$submodule.zip; \
	   cd ..;                                                          \
	 done;                                                             \
	 cd ${ARCHIVE_FOLDER};                                             \
	 rm -rf *.zip;                                                     \
	 zip -r ${ARCHIVE_NAME}.zip ${ARCHIVE_NAME};                       \
	 rm -rf tmp ${ARCHIVE_NAME}
archive-remote:
	@rm -rf ${ARCHIVE_FOLDER}/*;                                          \
	 mkdir -p ${ARCHIVE_FOLDER};                                          \
	 git clone --depth 1 --recursive ${REPO_URL}                          \
	                                   ${ARCHIVE_FOLDER}/${ARCHIVE_NAME}; \
	 cd ${ARCHIVE_FOLDER};                                                \
	 zip -r ${ARCHIVE_NAME}.zip ${ARCHIVE_NAME} --exclude \*.git *.git/*; \
	 rm -rf ${ARCHIVE_NAME}
clean:
	xcodebuild -configuration Debug clean
	xcodebuild -configuration Release clean
distclean:
	rm -rf bin build ${ARCHIVE_FOLDER}
