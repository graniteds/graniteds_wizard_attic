<%
	if (!flexBuilder)
		throw new org.granite.wizard.CancelFileGenerationException();

%><?xml version="1.0" encoding="UTF-8" standalone="no"?>
<actionScriptProperties
  analytics="false"
  mainApplicationPath="${projectName}.mxml"
  projectUUID="${ UUID.randomUUID().toString().toUpperCase() }"
  version="6">

  <compiler
  	additionalCompilerArguments="
	  -locale en_US
	  -services ../ear/war/WEB-INF/flex/services-config.xml
	  -context-root /${projectName}
	  -include-libraries ../lib/granite-essentials.swc
	  -keep-as3-metadata=Bindable,Managed,ChangeEvent,NonCommittingChangeEvent,Transient,Name,In,Inject,Out,Observer,Destroy,Id,Version,Size,Future,Pattern
	"
	autoRSLOrdering="true"
	copyDependentFiles="true"
	fteInMXComponents="false"
	generateAccessible="true"
	htmlExpressInstall="true"
	htmlGenerate="true"
	htmlHistoryManagement="true"
	htmlPlayerVersionCheck="true"
	includeNetmonSwc="false"
	outputFolderPath="${flexBinDir}"
	sourceFolderPath="${flexSrcDir}"
	strict="true"
	targetPlayerVersion="0.0.0"
	useApolloConfig="false"
	useDebugRSLSwfs="true"
	verifyDigests="true"
	warn="true">

    <compilerSourcePath/>
    <libraryPath defaultLinkType="0">
      <libraryPathEntry kind="4" path="">
        <excludedEntries>
          <libraryPathEntry kind="3" linkType="1" path="\${PROJECT_FRAMEWORKS}/libs/flex.swc" useDefaultLinkType="false"/>
        </excludedEntries>
      </libraryPathEntry>
      <libraryPathEntry kind="1" linkType="1" path="lib"/>
    </libraryPath>
    <sourceAttachmentPath/>
  </compiler>

  <applications>
    <application path="${projectName}.mxml"/>
  </applications>

  <modules/>

  <buildCSSFiles/>

</actionScriptProperties>