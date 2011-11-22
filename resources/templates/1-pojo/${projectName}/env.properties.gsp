<%
	import org.granite.wizard.util.Util;

	if (!antBuild)
		throw new org.granite.wizard.CancelFileGenerationException();

%>project.name = ${Util.escapeBackslashes(projectName)}
flex.home = ${Util.escapeBackslashes(flexSdkDir)}
flex.src.dir = ${Util.escapeBackslashes(flexSrcDir)}
flex.bin.dir = ${Util.escapeBackslashes(flexBinDir)}
java.src.dir = ${Util.escapeBackslashes(javaSrcDir)}
java.bin.dir = ${Util.escapeBackslashes(javaBinDir)}
build.dir = ${Util.escapeBackslashes(buildDir)}
deploy.dir = ${Util.escapeBackslashes(deployDir)}
