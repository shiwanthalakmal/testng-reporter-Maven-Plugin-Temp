package se.cambio.test.taf.testngreporter;

import com.google.common.io.Files;

import java.io.File;
import java.io.FileFilter;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.ArrayList;
import java.util.List;
import org.apache.commons.io.FileUtils;
import org.apache.commons.io.IOUtils;

/*
 * This class specifies class file version 49.0 but uses Java 6 signatures.  Assumed Java 6.
 */
public final class CreateXSLTReport {
    private final String testnginputfolder;
    private final String reportsOutputDir;
    private final String consolidatedReportActive;
    private final String hudsonModeActive;
    private final String archivedModeActive;
    private final String reportModules;
    private final String testngResultsXML = "/testng-results.xml";

    public CreateXSLTReport(String testnginputfolder, String outputDir, String hudsonModeActive, String consolidatedReportActive, String archivedModeActive, String reportModules) {
        this.testnginputfolder = testnginputfolder;
        this.reportsOutputDir = outputDir;
        this.hudsonModeActive = hudsonModeActive;
        this.archivedModeActive = archivedModeActive;
        this.consolidatedReportActive = consolidatedReportActive;
        this.reportModules = reportModules;
    }

    private String getResultsXMLFile() {
        if (!this.consolidatedReportActive.equalsIgnoreCase("false") && this.consolidatedReportActive.equalsIgnoreCase("true")) {
            new ProcessResultsXML().buildConsolidatedResultsXML(this.testnginputfolder + "/testng-results.xml", this.reportModules, this.hudsonModeActive, this.archivedModeActive);
        }
        return "/testng-results.xml";
    }

    public final String generateReport() throws Exception {
        return this.generateReport(this.reportsOutputDir);
    }

    private void copyFileFromResources(File file, String resourcePath) throws Exception {
        InputStream is = this.getClass().getClassLoader().getResourceAsStream(resourcePath);
        FileOutputStream os = new FileOutputStream(file);
        IOUtils.copy((InputStream)is, (OutputStream)os);
        os.close();
    }

    public final String generateReport(String reportoutputfolder) throws Exception {
        File inputfolder = new File(this.testnginputfolder);
        File outputfolder = new File(reportoutputfolder);
        inputfolder.mkdirs();
        outputfolder.mkdirs();
        SAXONLiaison saxonxsltreport = new SAXONLiaison();
        File imagesFolder = new File(reportoutputfolder + "/images");
        imagesFolder.mkdirs();
        File fileCloseImage = new File(reportoutputfolder + "/images/close.gif");
        this.copyFileFromResources(fileCloseImage, "images/close.gif");
        File fileOpenImage = new File(reportoutputfolder + "/images/open.gif");
        this.copyFileFromResources(fileOpenImage, "images/open.gif");
        File filePearsonLogo = new File(reportoutputfolder + "/images/jenkins-icon.png");
        this.copyFileFromResources(filePearsonLogo, "images/jenkins-icon.png");
        if (this.consolidatedReportActive.equalsIgnoreCase("false")) {
            File fileXslStyle = new File(reportoutputfolder + "/temp_report_xsl_style.xsl");
            this.copyFileFromResources(fileXslStyle, "report_xsl_style.xsl");
            saxonxsltreport.setStylesheet(fileXslStyle);
        } else if (this.consolidatedReportActive.equalsIgnoreCase("true")) {
            File baseTestNGResults = new File(inputfolder + "/testng-results.xml");
            this.copyFileFromResources(baseTestNGResults, "testng-results.xml");
            File fileXslStyle = new File(reportoutputfolder + "/temp_report_xsl_style.xsl");
            this.copyFileFromResources(fileXslStyle, "report_xsl_style_consolidated.xsl");
            saxonxsltreport.setStylesheet(fileXslStyle);
        }
        saxonxsltreport.addParam("testNgXslt.outputDir", outputfolder.getAbsolutePath());
        saxonxsltreport.addParam("testNgXslt.sortTestCaseLinks", "true");
        saxonxsltreport.addParam("testNgXslt.testDetailsFilter", "FAIL,SKIP,PASS,BY_CLASS");
        saxonxsltreport.addParam("testNgXslt.showRuntimeTotals", "true");
        saxonxsltreport.transform(new File(this.testnginputfolder + this.getResultsXMLFile()), new File(outputfolder + "/index.html"));
        List<File> pngfiles = CreateXSLTReport.listFiles(inputfolder, (FileFilter)new pngFileFilter(), true);
        for (File pngfile : pngfiles) {
            Files.copy((File)pngfile, (File)new File(outputfolder + "/" + pngfile.getName()));
        }

        // Copy Screenshots
        File screenshot_inputDir = new File(this.testnginputfolder+"/../screenshots/");
        if (screenshot_inputDir.exists()) {
            FileUtils.copyDirectoryToDirectory((File) screenshot_inputDir, (File) outputfolder);
        }

        FileUtils.copyDirectoryToDirectory((File)inputfolder, (File)outputfolder);
        return reportoutputfolder;
    }

    public static final List<String> getFailuedSuiteFiles(File inputfolder) {
        ArrayList<String> failedXMLSuites = new ArrayList<String>();
        List<File> failedXMLFiles = CreateXSLTReport.listFiles(inputfolder, (FileFilter)new failedXMLFileFilter(), true);
        if (failedXMLFiles.size() > 1) {
            failedXMLFiles.remove(failedXMLFiles.size() - 1);
        }
        for (File failedXMlFile : failedXMLFiles) {
            failedXMLSuites.add(failedXMlFile.getAbsolutePath());
        }
        return failedXMLSuites;
    }

    private static final List<File> listFiles(File rootDir, FileFilter filter, boolean recursive) {
        File[] files;
        ArrayList<File> result = new ArrayList<File>();
        if (!rootDir.exists() || !rootDir.isDirectory()) {
            return result;
        }
        for (File f : files = rootDir.listFiles(filter)) {
            if (result.contains(f)) continue;
            result.add(f);
        }
        if (recursive) {
            File[] dirs;
            for (File f2 : dirs = rootDir.listFiles((FileFilter)new DirFilter())) {
                if (!f2.canRead()) continue;
                result.addAll(CreateXSLTReport.listFiles(f2, filter, recursive));
            }
        }
        return result;
    }

    /**
     * Created by kalwis on 6/10/2016.
     */
    private static final class DirFilter implements FileFilter{
        private DirFilter() {
        }

        public boolean accept(File pathname) {
            if (pathname.isDirectory()) {
                return true;
            }
            return false;
        }
    }

    private static final class failedXMLFileFilter implements FileFilter {
        private failedXMLFileFilter() {
        }

        public boolean accept(File pathname) {
            if (pathname.getName().contentEquals("testng-failed.xml")) {
                return true;
            }
            return false;
        }
    }

    private static final class pngFileFilter implements FileFilter {
        private pngFileFilter() {
        }

        public boolean accept(File pathname) {
            String suffix = ".png";
            if (pathname.getName().toLowerCase().endsWith(suffix)) {
                return true;
            }
            return false;
        }
    }
}
