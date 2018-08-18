import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;

public class QueryMaker {
	public static void main(String[] args) throws IOException {
		BufferedWriter bwQuerySet = new BufferedWriter(new FileWriter(new File("query2.txt")));
		try {

			File fXmlFile = new File("trecFormat.txt");
			DocumentBuilderFactory dbFactory = DocumentBuilderFactory.newInstance();
			DocumentBuilder dBuilder = dbFactory.newDocumentBuilder();
			Document doc = dBuilder.parse(fXmlFile);

			doc.getDocumentElement().normalize();

			System.out.println("Root element :" + doc.getDocumentElement().getNodeName());

			NodeList nList = doc.getElementsByTagName("DOC");

			System.out.println("----------------------------");

			for (int temp = 0; temp < nList.getLength(); temp++) {
				int row = temp + 1;
				Node nNode = nList.item(temp);
				// System.out.println("\nCurrent Element :" +
				// nNode.getNodeName());
				if (nNode.getNodeType() == Node.ELEMENT_NODE) {
					Element eElement = (Element) nNode;

					System.out.println("doc no : " + eElement.getElementsByTagName("DOCNO").item(0).getTextContent());
					String content = eElement.getElementsByTagName("TEXT").item(0).getTextContent();
					String regex = "(\\n|^).*?(?=\\n|$)";
					Pattern pattern = Pattern.compile(regex);
					Matcher matcher = pattern.matcher(content);
					int segmentCounter = 1;
					while (matcher.find()) {
						System.out.println("doc number "+row);
						
						String queryString = matcher.group(0).replaceAll("\n", "");
						if(queryString.length()>50)
						{
							bwQuerySet.write("<DOC query_"+row+"_"+segmentCounter+++">"+"\n");
							bwQuerySet.write(queryString+"\n");
							bwQuerySet.write("</DOC>"+"\n");
						}
					}

				}
			}
			bwQuerySet.close();
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

}
