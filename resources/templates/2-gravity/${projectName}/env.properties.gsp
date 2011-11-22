<%
	import org.granite.generator.Fs;

	if (!antBuild)
		throw new org.granite.wizard.CancelFileGenerationException();

%>project.name = ${Fs.escapeBackslashes(projectName)}
flex.home = ${Fs.escapeBackslashes(flexSdkDir)}
flex.src.dir = ${Fs.escapeBackslashes(flexSrcDir)}
flex.bin.dir = ${Fs.escapeBackslashes(flexBinDir)}
build.dir = ${Fs.escapeBackslashes(buildDir)}
deploy.dir = ${Fs.escapeBackslashes(deployDir)}

