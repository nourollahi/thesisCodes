package parser;

import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.jsoup.nodes.Element;
import org.jsoup.select.Elements;

public class ParseNews {

	public static String parse(String htmlContent,String source,String url) {
		String mainContent = "";
		htmlContent = htmlContent.replaceAll("ی", "ي");
		Document doc = Jsoup.parse(htmlContent);
		try {
			if (source.equals("khabaronline"))
			{
				try{
				Element mainBodyElement = doc.select("div.body").first();
				Elements paragrphs = mainBodyElement.children();
				StringBuilder sb = new StringBuilder("");
				for (Element element : paragrphs) {
					sb.append(element.text());
					sb.append("\n");
				}
				mainContent = sb.toString();
				}
				catch(Exception e)
				{
					System.err.println("some thing  wrong in "+ url+".error is: "+e);
				}
			}
			if(source.equals("tabnak"))
			{
				try{
					mainContent = doc.select("div.body").first().toString();
					mainContent = mainContent.replaceAll("<br>", "\n");
					mainContent = mainContent.replaceAll("<div class=\"body\">", "");
					mainContent = mainContent.replaceAll("<div class=\"wrapper\"></div>", "");
					mainContent = mainContent.replaceAll("&nbsp;", "");
					
					mainContent = mainContent.replaceAll("</div>", "");
					}
					catch(Exception e)
					{
						System.err.println("some thing going wrong in "+ url+".error is: "+e);
						return "";
					}
			}
		} catch (Exception e) {
			return "";
		}
		return mainContent;

	}

}
