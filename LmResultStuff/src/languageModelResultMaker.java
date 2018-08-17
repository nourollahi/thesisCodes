import java.io.File;
import java.io.FileNotFoundException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.LinkedHashMap;
import java.util.NoSuchElementException;
import java.util.Scanner;

public class languageModelResultMaker {
	public static void main(String[] args) throws FileNotFoundException {
		Scanner scanner;
		int docNumber = 104;
		int kParameter=5;
		LinkedHashMap<String, ArrayList<String>> doc2segments = new LinkedHashMap<>();
		try {
			scanner = new Scanner(new File("res-plm"));

			while (scanner.hasNext()) {

				String line = scanner.nextLine();// query_1_1 doc_1_1141599
													// -1.77573
				String[] lineParts = line.split(" ");// query_1_1 doc_1_1141599
														// -1.77573
				String[] tmp = lineParts[0].split("_");
				String docID = tmp[1];
				if (doc2segments.containsKey(docID)) {
					ArrayList<String> segments = doc2segments.get(docID);
					segments.add(line);
					doc2segments.put(docID, segments);
				} else {
					ArrayList<String> tmp00 = new ArrayList<>();
					tmp00.add(line);
					doc2segments.put(docID, tmp00);
				}
			}
			scanner.close();
			for (String docId : doc2segments.keySet()) {
				LinkedHashMap<String, ArrayList<String>> segment2scores = new LinkedHashMap<>();
				ArrayList<String> segments = doc2segments.get(docId);
				for (String line : segments) {
					String[] lineParts = line.split(" ");// query_1_1
															// doc_1_1141599
															// -1.77573
					String[] tmp = lineParts[0].split("_");
					String segID = tmp[2];
					if (segment2scores.containsKey(segID)) {
						ArrayList<String> segment = segment2scores.get(segID);
						segment.add(line);
						segment2scores.put(segID, segment);
					} else {
						ArrayList<String> tmp00 = new ArrayList<>();
						tmp00.add(line);
						segment2scores.put(segID, tmp00);
					}
				}
				// process each segment now
				for (String segmentID : segment2scores.keySet()) {
					System.out.println("docID " + docId+" segmentID " + segmentID);
					ArrayList<String> uniqueSegmentList = segment2scores.get(segmentID);
					double[] scores = new double[docNumber];
					LinkedHashMap<Integer, Double> doc2Score = new LinkedHashMap<>();
					for (String segmentLine : uniqueSegmentList) {
						String[] lineParts = segmentLine.split(" ");// query_1_1
																	// doc_1_1141599
																	// -1.77573
						String[] tmp = lineParts[1].split("_");
						int docID = Integer.parseInt(tmp[1]);
						double score = Double.parseDouble(lineParts[2]);
						scores[docID - 1] = score;
						doc2Score.put(docID, score);
					}
					// hala az docID koochiktar ro sort kon o khorooji bede
					
					int size = Integer.parseInt(docId)-1;
					scores[size]=Double.NEGATIVE_INFINITY;
					doc2Score.put(Integer.parseInt(docId),Double.NEGATIVE_INFINITY);
//					double[] part = new double[size];
//					System.arraycopy(scores, 0, part, 0, size);
					//int[] biggestElement = indexesOfTopElements(scores,kParameter);
					int counter=0;
					for (Integer doc : doc2Score.keySet()) {
						if(doc<Integer.parseInt(docId))
						{
							if(counter<=kParameter)
							{
								System.out.println("doc "+doc+" "+doc2Score.get(doc));
								counter++;
							}
						}
					}
//					System.out.println("");
				}
				System.out.println("================================================");
			}

		} catch (NoSuchElementException e) {
			e.printStackTrace();
		}
	}
	 static int[] indexesOfTopElements(double[] orig, int nummax) {
		 double[] copy = Arrays.copyOf(orig,orig.length);
	        Arrays.sort(copy);
	        if(nummax>orig.length)
	        {
	        	nummax =orig.length;
	        }
	     
	        double[] honey = Arrays.copyOfRange(copy,copy.length - nummax, copy.length);
	        int[] result = new int[nummax];
	        int resultPos = 0;
	        for(int i = 0; i < orig.length; i++) {
	        	double onTrial = orig[i];
	            int index = Arrays.binarySearch(honey,onTrial);
	            if(index < 0) continue;
	            result[resultPos++] = i;
	        }
	        return result;
	    }
}
