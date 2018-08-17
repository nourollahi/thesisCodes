import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.util.Arrays;
import java.util.LinkedHashMap;

public class TagReader {
	public static void main(String[] args) throws IOException {
		BufferedWriter bw = new BufferedWriter(new FileWriter("OldNewPlain.txt"));
		BufferedReader tags = new BufferedReader(new FileReader("Tags.txt"));
		BufferedReader event = new BufferedReader(new FileReader("allNewsPlain.txt"));
		LinkedHashMap<String, String> tagsHashMap = new LinkedHashMap<>();
		LinkedHashMap<String,String> newsHashMap = new LinkedHashMap<>();
		String currentLine;
		while ((currentLine = tags.readLine()) != null) {
			String[] tmp = currentLine.split("\t");
//			System.out.println(Arrays.toString(tmp));
			//if (tmp[1].contains("جدید") || tmp[1].contains("قدیمی")) {
				tagsHashMap.put(tmp[0], tmp[1]);
			//}
		}
		tags.close();
		
		String currentLine2;
		event.readLine();
		int counter = 0;
		while ((currentLine2=event.readLine())!=null)
		{
			counter++;
			newsHashMap.put(counter+"", currentLine2);
		}
		
		for (String key:tagsHashMap.keySet())
		{
			if (tagsHashMap.get(key).contains("جديد") ||tagsHashMap.get(key).contains("قديمي") )
			{
				String news = newsHashMap.get(key);
//				System.out.println(key);
				news = news.replace("?"," ");
				String[] tmp = news.split("\t");
				System.out.println(tmp[0]+"-"+tagsHashMap.get(key));
			bw.write(news);
			bw.write("\n");
			}
		}
		bw.close();
		event.close();
	}
}
