/*
 * Decompiled with CFR 0_114.
 * 
 * Could not load the following classes:
 *  CreateXSLTReport
 *  org.apache.maven.plugin.AbstractMojo
 *  org.apache.maven.plugin.MojoExecutionException
 *  org.apache.maven.plugin.logging.Log
 *  org.apache.maven.plugins.annotations.LifecyclePhase
 *  org.apache.maven.plugins.annotations.Mojo
 *  org.apache.maven.plugins.annotations.Parameter
 */
package se.cambio.test.taf.testngreporter;

import java.io.IOException;
import org.apache.maven.plugin.AbstractMojo;
import org.apache.maven.plugin.MojoExecutionException;
import org.apache.maven.plugins.annotations.LifecyclePhase;
import org.apache.maven.plugins.annotations.Mojo;
import org.apache.maven.plugins.annotations.Parameter;

@Mojo(name="report", defaultPhase=LifecyclePhase.TEST)
public class TestNGReporterMojo extends AbstractMojo {
    @Parameter(property="propArchivedModeActive", defaultValue="false")
    private String archivedModeActive;
    @Parameter(property="propHudsonModeActive", defaultValue="false")
    private String hudsonModeActive;
    @Parameter(property="propConsolidatedReportActive", defaultValue="false")
    private String consolidatedReportActive;
    @Parameter(property="propReportModules")
    private String reportModules;
    @Parameter(property="propInputDir", required=true)
    private String inputDir;
    @Parameter(property="propOutputDir", required=true)
    private String outputDir;
    @Parameter(property="skipTests", defaultValue="false", readonly=true)
    private boolean skipTests;

    public void execute() throws MojoExecutionException {
        if (this.skipTests) {
            this.getLog().info((CharSequence)"skipping testngreporter");
        } else {
            CreateXSLTReport xsltreport = new CreateXSLTReport(this.inputDir, this.outputDir, this.hudsonModeActive, this.consolidatedReportActive, this.archivedModeActive, this.reportModules);
            try {
                String locLastReport = xsltreport.generateReport();
            }
            catch (IOException e) {
                this.getLog().info((CharSequence)("Error Generating report: " + e.getMessage()));
                throw new MojoExecutionException("Error Generating report", (Exception)e);
            }
            catch (Exception e) {
                e.printStackTrace();
            }
        }
    }
}
