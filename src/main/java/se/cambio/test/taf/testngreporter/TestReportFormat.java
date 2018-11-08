package se.cambio.test.taf.testngreporter;

import org.apache.maven.plugin.MojoExecutionException;
import org.apache.maven.plugins.annotations.Parameter;

import java.io.IOException;

public class TestReportFormat {

    @Parameter(property="propArchivedModeActive", defaultValue="false")
    private static String archivedModeActive;

    @Parameter(property="propHudsonModeActive", defaultValue="false")
    private static String hudsonModeActive;

    @Parameter(property="propConsolidatedReportActive", defaultValue="false")
    private static String consolidatedReportActive;

    @Parameter(property="propReportModules")
    private static String reportModules;

    @Parameter(property="propInputDir", required=true)
    private static String inputDir;

    @Parameter(property="propOutputDir", required=true)
    private static String outputDir;

    @Parameter(property="skipTests", defaultValue="false", readonly=true)
    private static boolean skipTests;

    public static void main(String[] args) throws MojoExecutionException {

        inputDir = "C:\\Temp\\Report\\surefire-reports";
        outputDir = "C:\\Temp\\Report\\output-dir";

        CreateXSLTReport xsltreport = new CreateXSLTReport(inputDir, outputDir, hudsonModeActive, "false", archivedModeActive, reportModules);
        try {
            String locLastReport = xsltreport.generateReport();
        }
        catch (IOException e) {
//            this.getLog().info((CharSequence)("Error Generating report: " + e.getMessage()));
            throw new MojoExecutionException("Error Generating report", (Exception)e);
        }
        catch (Exception e) {
            e.printStackTrace();
        }
    }
}
