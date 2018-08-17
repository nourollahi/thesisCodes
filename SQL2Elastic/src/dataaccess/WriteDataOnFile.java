package dataaccess;

import java.io.BufferedWriter;
import java.io.FileWriter;
import java.io.IOException;
import java.util.HashMap;
import java.util.LinkedList;


public class WriteDataOnFile {
	public static void main(String[] args) throws IOException {
//		String query = "(ÔåÑíÇÑí AND ãÌíÏ)"+" OR "+"(ãÕØİí AND ÇÍãÏí AND ÑæÔä)"+" OR "+"(ãÓÚæÏ AND ÚáíãÍãÏí)"+" OR "+"(ÏÇÑíæÔ AND ÑÖÇíí AND äÇÏ)"+" OR "+"(ãÓÚæÏ AND Úáí AND ãÍãÏí)"+" OR "+"(ÏÇÑíæÔ AND ÑÖÇííäÇÏ)";
		String query ="(ÓŞæØ AND åæÇíãÇ)";
		BufferedWriter bw = new BufferedWriter(new FileWriter("allNewsPlain.txt"));
		bw.write("new-id	khabargozary	id	date	titr	content");
		bw.newLine();
		 NewsServiceResult newsServiceResult = NewsSAO.search(query, "news_index", "news_type");
		 LinkedList<HashMap<String, String>> tmp = (LinkedList<HashMap<String, String>>) newsServiceResult.getResult();
		  for (HashMap<String, String> hashMap : tmp) {
			  String agencyId = hashMap.get("agency-id");
			  String[] agencIdArray = agencyId.split("-");
			  bw.write(hashMap.get("agency-id")+"\t");//new Id equals to agency-ID
			  bw.write(agencIdArray[0]+"\t");//agency
			  bw.write(agencIdArray[1]+"\t");//id
			  bw.write(hashMap.get("year")+"/"+hashMap.get("month")+"/"+hashMap.get("day")+ "-");//date
			  bw.write(hashMap.get("hour")+":"+hashMap.get("minute")+"\t");//time
			  String titr = hashMap.get("titr").replace(System.getProperty("line.separator"), "").replace("\r", "");
			  bw.write(titr+"\t");
			  String content = hashMap.get("content");
			  content = content.replace(System.getProperty("line.separator"), "").replace("\r", "");
			  bw.write(content);
			  bw.newLine();
		}
		  bw.close();
		 System.out.println("write of file done");
	}

}
