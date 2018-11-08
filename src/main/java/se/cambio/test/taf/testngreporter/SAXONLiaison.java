package se.cambio.test.taf.testngreporter;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import javax.xml.transform.Result;
import javax.xml.transform.Source;
import javax.xml.transform.Templates;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.stream.StreamResult;
import javax.xml.transform.stream.StreamSource;
import org.apache.tools.ant.taskdefs.XSLTLiaison;

public class SAXONLiaison
implements XSLTLiaison {
    private TransformerFactory tfactory = TransformerFactory.newInstance();
    private FileInputStream xslStream = null;
    private Templates templates = null;
    private Transformer transformer = null;

    public void setStylesheet(File stylesheet) throws Exception {
        this.xslStream = new FileInputStream(stylesheet);
        StreamSource src = new StreamSource(this.xslStream);
        src.setSystemId(this.getSystemId(stylesheet));
        this.templates = this.tfactory.newTemplates(src);
        this.transformer = this.templates.newTransformer();
    }

    public void transform(File infile, File outfile) throws Exception {
        FileInputStream fis = null;
        FileOutputStream fos = null;
        try {
            fis = new FileInputStream(infile);
            fos = new FileOutputStream(outfile);
            StreamSource src = new StreamSource(fis);
            src.setSystemId(this.getSystemId(infile));
            StreamResult res = new StreamResult(fos);
            res.setSystemId(this.getSystemId(outfile));
            this.transformer.transform(src, res);
        }
        finally {
            try {
                if (this.xslStream != null) {
                    this.xslStream.close();
                }
            }
            catch (IOException ignored) {}
            try {
                if (fis != null) {
                    fis.close();
                }
            }
            catch (IOException ignored) {}
            try {
                if (fos != null) {
                    fos.close();
                }
            }
            catch (IOException ignored) {}
        }
    }

    protected String getSystemId(File file) {
        String path = file.getAbsolutePath();
        path = path.replace('\\', '/');
        return "file://" + path;
    }

    public void addParam(String name, String value) {
        this.transformer.setParameter(name, value);
    }
}
