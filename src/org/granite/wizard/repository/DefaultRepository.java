package org.granite.wizard.repository;

import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileFilter;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.URI;
import java.net.URL;
import java.net.URLConnection;
import java.util.Properties;
import java.util.UUID;

import org.eclipse.core.runtime.SubMonitor;
import org.granite.generator.util.PropertiesUtil;
import org.granite.wizard.DynamicProjectWizard;
import org.granite.wizard.ProjectTemplate;

public class DefaultRepository implements Repository {

	public static final String REPOSITORY_DIRECTORY = "repository";
	public static final String REPOSITORY_FILE = "index.properties";
	
	protected DynamicProjectWizard wizard = null;
	protected ProjectTemplate template = null;
	
	protected File repositoryDir = null;
	protected Properties repositoryIndex;
	
	@Override
	public synchronized void initialize(DynamicProjectWizard wizard, ProjectTemplate template) throws IOException {
		this.wizard = wizard;
		this.template = template;
		
		repositoryDir = new File(template.getResourcesDirectory(), REPOSITORY_DIRECTORY);
		if (!repositoryDir.exists()) {
			if (!repositoryDir.mkdirs())
				throw new RuntimeException("Could not create repository directory: " + repositoryDir);
		}
		
		try {
			repositoryIndex = PropertiesUtil.loadProperties(repositoryDir, REPOSITORY_FILE, true);
		}
		catch (IOException e) {
			repositoryIndex = new Properties();
			PropertiesUtil.storeProperties(repositoryIndex, repositoryDir, REPOSITORY_FILE, true);
		}
	}
	
	public File getFile(URI uri) throws IOException {
		return getFile(uri, null);
	}

	@Override
	public synchronized File getFile(URI uri, SubMonitor monitor) throws IOException {
		File repositoryFile = null;

		final String key = uri.toString();
		
		String fileName = repositoryIndex.getProperty(key);
		if (fileName != null) {
			repositoryFile = new File(repositoryDir, fileName);
			if (!repositoryFile.exists()) {
				repositoryFile = null;
				repositoryIndex.remove(uri);
				PropertiesUtil.storeProperties(repositoryIndex, repositoryDir, REPOSITORY_FILE, true);
			}
		}
		
		if (repositoryFile == null) {			
			File temporaryFile = downloadUri(uri, monitor);
			if (temporaryFile != null) {
				fileName = UUID.randomUUID().toString();
				repositoryFile = new File(repositoryDir, fileName);
				if (!temporaryFile.renameTo(repositoryFile)) {
					repositoryFile = null;
					temporaryFile.delete();
				}
				else {
					temporaryFile = repositoryFile;
					repositoryIndex.setProperty(key, fileName);
					PropertiesUtil.storeProperties(repositoryIndex, repositoryDir, REPOSITORY_FILE, true);
				}
			}
		}
		
		// Redundant check...
		if (repositoryFile == null)
			throw new IOException("Could not get file: " + uri);
		
		return repositoryFile;
	}

	@Override
	public synchronized boolean clearFile(URI uri) {
		String fileName = (String)repositoryIndex.remove(uri);
		if (fileName != null) {
			File repositoryFile = new File(repositoryDir, fileName);
			if (repositoryFile.exists())
				return repositoryFile.delete();
		}
		return false;
	}

	@Override
	public synchronized void clearAllFile() {
		repositoryIndex.clear();
		
		File[] files = repositoryDir.listFiles(new FileFilter() {
			@Override
			public boolean accept(File file) {
				return file.isFile();
			}
		});
		
		for (File file : files)
			file.delete();
	}
	
	protected File downloadUri(URI uri, SubMonitor monitor) throws IOException {
		File file = null;
		
		if (monitor != null)
			monitor.setTaskName("Downloading: " + uri);
		
		boolean error = false;
		
		OutputStream os = null;
		InputStream is = null;
		try {
			URL url = uri.toURL();
			
			URLConnection conn = url.openConnection();
			is = conn.getInputStream();

			file = File.createTempFile("gds", "wiz");
			os = new BufferedOutputStream(new FileOutputStream(file));

			int b;
			while ((b = is.read()) != -1)
				os.write(b);
		}
		catch (IOException e) {
			error = true;
			throw e;
		}
		catch (Exception e) {
			error = true;
			throw new IOException(e);
		}
		finally {
			if (is != null) try {
				is.close();
			}
			catch (Exception e) {
			}
			if (os != null) try {
				os.close();
			}
			catch (Exception e) {
			}
			if (error && file != null) {
				file.delete();
				file = null;
			}
		}

		return file;
	}
}
