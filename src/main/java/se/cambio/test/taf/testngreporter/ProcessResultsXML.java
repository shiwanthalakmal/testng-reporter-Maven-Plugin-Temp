package se.cambio.test.taf.testngreporter;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileFilter;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.util.ArrayList;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamResult;
import org.apache.commons.io.filefilter.WildcardFileFilter;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;

public class ProcessResultsXML {
    public static File findFilesInsideDir(File dir) {
        WildcardFileFilter fileFilter = new WildcardFileFilter("*-tests");
        File[] files = dir.listFiles((FileFilter)fileFilter);
        System.out.println("Results for Test Project: " + files[0]);
        return files[0];
    }

    private static int getBuildNumber(String file) {
        BufferedReader br = null;
        String everything = null;
        try {
            br = new BufferedReader(new FileReader(file));
        }
        catch (FileNotFoundException e) {
            e.printStackTrace();
        }
        try {
            StringBuilder sb = new StringBuilder();
            String line = br.readLine();
            while (line != null) {
                sb.append(line);
                sb.append(System.lineSeparator());
                line = br.readLine();
            }
            everything = sb.toString();
        }
        catch (IOException e) {
            e.printStackTrace();
        }
        finally {
            try {
                br.close();
            }
            catch (IOException e) {
                e.printStackTrace();
            }
        }
        System.out.println("Using Build: " + (Integer.parseInt(everything.trim()) - 1));
        return Integer.parseInt(everything.trim()) - 1;
    }

    private static String getModuleTestResultsFile(String parentProjName, String file) {
        System.out.println("Collecting results for Job: " + parentProjName);
        String moduleTestResultsFile = "";
        try {
            moduleTestResultsFile = ProcessResultsXML.findFilesInsideDir(new File(new StringBuilder().append(parentProjName).append("/builds/").append(ProcessResultsXML.getBuildNumber(new StringBuilder().append(parentProjName).append("/nextBuildNumber").toString())).append("/archive/").toString())).getCanonicalPath() + file;
        }
        catch (IOException e) {
            e.printStackTrace();
        }
        return moduleTestResultsFile;
    }

    private static String getModuleTestResultsFile(String parentProjName, String buildNumber, String file) {
        System.out.println("Collecting results for Job: " + parentProjName);
        String moduleTestResultsFile = "";
        try {
            moduleTestResultsFile = ProcessResultsXML.findFilesInsideDir(new File(new StringBuilder().append(parentProjName).append("/builds/").append(buildNumber).append("/archive/").toString())).getCanonicalPath() + file;
        }
        catch (IOException e) {
            e.printStackTrace();
        }
        return moduleTestResultsFile;
    }

    public String buildConsolidatedResultsXML(String sourceXml, String modulesList, String hudsonModeActive, String archivedModeActive) {
        ArrayList<Element> testList = new ArrayList<Element>();
        String homeDir = new File(new File(new File(sourceXml).getParent()).getParent()).getParent();
        String[] strArr = modulesList.split(",");
        try {
            for (int a = 0; a < strArr.length; ++a) {
                String moduleTestResults = null;
                try {
                    if (archivedModeActive.equalsIgnoreCase("false")) {
                        if (hudsonModeActive.equalsIgnoreCase("false")) {
                            moduleTestResults = ProcessResultsXML.getModuleTestResultsFile(homeDir + "/../" + strArr[a].trim(), "/target/surefire-reports/testng-results.xml");
                        } else if (hudsonModeActive.equalsIgnoreCase("true")) {
                            moduleTestResults = ProcessResultsXML.getModuleTestResultsFile(homeDir + "/../../" + strArr[a].trim(), "/target/surefire-reports/testng-results.xml");
                        }
                    } else if (archivedModeActive.equalsIgnoreCase("true")) {
                        String moduleAndBuild = strArr[a].trim();
                        String module = moduleAndBuild.split(":")[0];
                        String buildNumber = moduleAndBuild.split(":")[1];
                        if (hudsonModeActive.equalsIgnoreCase("false")) {
                            moduleTestResults = ProcessResultsXML.getModuleTestResultsFile(homeDir + "/../" + module, buildNumber, "/target/surefire-reports/testng-results.xml");
                        } else if (hudsonModeActive.equalsIgnoreCase("true")) {
                            moduleTestResults = ProcessResultsXML.getModuleTestResultsFile(homeDir + "/../../" + module, buildNumber, "/target/surefire-reports/testng-results.xml");
                        }
                    }
                    File f = new File(moduleTestResults);
                    Document doc = null;
                    DocumentBuilderFactory docFactory = DocumentBuilderFactory.newInstance();
                    DocumentBuilder docBuilder = docFactory.newDocumentBuilder();
                    if (!f.exists()) {
                        System.out.println("No File Found: " + f.getCanonicalPath());
                        System.exit(0);
                        continue;
                    }
                    doc = docBuilder.parse(f.getCanonicalPath());
                    Node testResultsNode = doc.getFirstChild();
                    NodeList testResultChildNodes = testResultsNode.getChildNodes();
                    NodeList suteChildNodes = null;
                    Node testNode = null;
                    block6 : for (int i = 0; i < testResultChildNodes.getLength(); ++i) {
                        if (!testResultChildNodes.item(i).getNodeName().equalsIgnoreCase("suite")) continue;
                        suteChildNodes = testResultChildNodes.item(i).getChildNodes();
                        for (int j = 0; j < suteChildNodes.getLength(); ++j) {
                            if (!suteChildNodes.item(j).getNodeName().equalsIgnoreCase("test")) continue;
                            testNode = suteChildNodes.item(j);
                            break block6;
                        }
                    }
                    testList.add((Element)testNode);
                    continue;
                }
                catch (Exception e) {
                    e.printStackTrace();
                }
            }
            File file = new File(sourceXml);
            Document sourceDoc = null;
            DocumentBuilderFactory docFactory = DocumentBuilderFactory.newInstance();
            DocumentBuilder docBuilder = docFactory.newDocumentBuilder();
            Node suiteNode = null;
            if (!file.exists()) {
                System.out.println("No File Found: " + file.getCanonicalPath());
            } else {
                sourceDoc = docBuilder.parse(file.getCanonicalPath());
                Node testResultsNode = sourceDoc.getFirstChild();
                NodeList testResultChildNodes = testResultsNode.getChildNodes();
                for (int i = 0; i < testResultChildNodes.getLength(); ++i) {
                    if (!testResultChildNodes.item(i).getNodeName().equalsIgnoreCase("suite")) continue;
                    suiteNode = testResultChildNodes.item(i);
                    break;
                }
            }
            if (testList.size() >= 1) {
                for (Element testElement : testList) {
                    Node firstDocImportedNode = sourceDoc.importNode(testElement, true);
                    suiteNode.appendChild(firstDocImportedNode);
                }
            } else {
                System.out.println("No Results files found for Test Modules");
                System.exit(0);
            }
            TransformerFactory transformerFactory = TransformerFactory.newInstance();
            Transformer transformer = transformerFactory.newTransformer();
            DOMSource source = new DOMSource(sourceDoc);
            StreamResult result = new StreamResult(new File(sourceXml));
            transformer.transform(source, result);
            this.formatXMLFile(sourceXml);
        }
        catch (ParserConfigurationException e) {
            e.printStackTrace();
        }
        catch (Exception e2) {
            e2.printStackTrace();
        }
        return sourceXml;
    }

    public void formatXMLFile(String filePath) {
        File f = new File(filePath);
        try {
            Document doc = null;
            DocumentBuilderFactory docFactory = DocumentBuilderFactory.newInstance();
            DocumentBuilder docBuilder = docFactory.newDocumentBuilder();
            if (f.exists()) {
                doc = docBuilder.parse(filePath);
                TransformerFactory transformerFactory = TransformerFactory.newInstance();
                Transformer transformer = transformerFactory.newTransformer();
                transformer.setOutputProperty("indent", "yes");
                transformer.setOutputProperty("{http://xml.apache.org/xslt}indent-amount", "3");
                DOMSource source = new DOMSource(doc);
                StreamResult result = new StreamResult(new File(filePath));
                transformer.transform(source, result);
            }
        }
        catch (ParserConfigurationException e) {
            e.printStackTrace();
        }
        catch (Exception e2) {
            e2.printStackTrace();
        }
    }
}
