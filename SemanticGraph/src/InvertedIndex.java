

import java.io.BufferedReader;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Set;
 
public class InvertedIndex {
 
	
 
	public HashMap<String, List<Tuple>> index = new HashMap<String, List<Tuple>>();
	public List<Integer> files = new ArrayList<Integer>();
	public Set<Integer> answer = new HashSet<Integer>();
 
	public void indexFile(String doc,int docnum) throws IOException {
		int fileno = files.indexOf(docnum);
		if (fileno == -1) {
			files.add(docnum);
			fileno = files.size() - 1;
		}
 
		int pos = 0;
	//	@SuppressWarnings("resource")
		//BufferedReader reader = new BufferedReader(new FileReader(file));
//		for (String line = reader.readLine(); line != null; line = reader
//				.readLine()) {
			for (String _word : doc.split("\\W+")) {
				String word = _word.toLowerCase();
				pos++;
				//if (stopwords.contains(word))
					//continue;
				List<Tuple> idx = index.get(word);
				if (idx == null) {
					idx = new LinkedList<Tuple>();
					index.put(word, idx);
				}
				idx.add(new Tuple(fileno, pos));
			}
		
		//System.out.println("indexed " + docnum + " " + pos + " words");
	}
 
	public Map<String, List<Tuple>> getIndex() {
		//for (String _word : words) {
			//Set<Integer> answer = new HashSet<Integer>();
//			//String word = _word.toLowerCase();
//			List<Tuple> idx = index.get(word);
//			if (idx != null) {
//				for (Tuple t : idx) {
//					answer.add(files.get(t.fileno));
//				}
//			}
//			System.out.print(word);
//			for (Integer f : answer) {
//				System.out.print(" " + f);
//			}
//			System.out.println("");
			return (HashMap<String, List<Tuple>>) index;
		}
			
	
 
	public  Map mainMethod(String datasetName) throws IOException {
		//try {
			InvertedIndex idx = new InvertedIndex();
			@SuppressWarnings("resource")
			BufferedReader reader = new BufferedReader(new FileReader(datasetName));
			int size=Integer.parseInt(reader.readLine());
			for (int i = 0; i < size; i++) {
				
				String doc=reader.readLine();
				idx.indexFile(doc,i);
			}
			System.out.println("Inverted Index created!");
			Map<String, List<Tuple>> myindex =new HashMap<String,List<Tuple>>();
			myindex=idx.getIndex();
			//idx.search("cat", myindex);
		//} catch (Exception e) {
		//	e.printStackTrace();
		//}
		return myindex;
	}
 
	public class Tuple {
		public int fileno;
		public int position;
 
		public Tuple(int fileno, int position) {
			this.fileno = fileno;
			this.position = position;
		}
	}

	public Set search(String word,Map index) {
		
		List<Tuple> idx = (List<Tuple>) index.get(word);
		Set<Integer> answer = new HashSet<Integer>();
		if (idx != null) {
			for (Tuple t : idx) {
				answer.add(t.fileno);
				//System.out.println(t.fileno);
			}
		}
		return answer;
	}
}