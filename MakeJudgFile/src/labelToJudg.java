import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.util.LinkedHashMap;
import java.util.LinkedList;

public class labelToJudg {

	public static void main(String[] args) throws IOException {
		String line;
		int lineNumber=1;
		LinkedHashMap<String,LinkedList<Integer>> label2DocsMap = new LinkedHashMap<String,LinkedList<Integer>>();
		BufferedReader br = new BufferedReader(new FileReader("label.txt"));
		while ((line = br.readLine()) != null) {
			LinkedList<Integer> tmp = label2DocsMap.get(line);
			if(tmp==null)
				tmp = new LinkedList<Integer>();
			tmp.add(lineNumber++);
			label2DocsMap.put(line, tmp);
		}
		for (String labels :label2DocsMap.keySet())  {
			System.out.println(label2DocsMap.get(labels));
		}
		br.close();
	}
}