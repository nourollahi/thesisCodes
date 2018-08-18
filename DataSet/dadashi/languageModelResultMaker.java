import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.NoSuchElementException;
import java.util.Scanner;

public class languageModelResultMaker {
	public static void main(String[] args) throws Exception {
		Scanner scanner;
		int docNumber = 450;
		int kParameter = 5;
		String PreDocId = "1";
		String CurrentDocID = "";
		int segmentCount = 0;
		BufferedWriter bw = new BufferedWriter(new FileWriter(new File("final-res-plm-3.txt")));
		LinkedHashMap<String, ArrayList<String>> doc2segments = new LinkedHashMap<>();
		HashMap<String, Integer> docId_segmentCount = new HashMap<>();
		try {
			scanner = new Scanner(new File("dadashi-res-plm-2"));

			while (scanner.hasNext()) {

				String line = scanner.nextLine();// query_1_1 doc_1_1141599
													// -1.77573
				String[] lineParts = line.split(" ");// query_1_1 doc_1_1141599
														// -1.77573
				String[] tmp = lineParts[0].split("_");
				String docID = tmp[1];
				docId_segmentCount.put(docID, Integer.parseInt(tmp[2]));
//				CurrentDocID = docID;
//				if ((PreDocId.equals(CurrentDocID))) {
//					PreDocId = CurrentDocID;
//					segmentCount++;
//				} else {
//					docId_segmentCount.put(docID, segmentCount);
//					System.out.println(segmentCount);
//					segmentCount =0;
//				}
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
			System.out.println(docId_segmentCount.get("60"));
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
				bw.write(docId_segmentCount.get(docId).toString());
				bw.newLine();
				// process each segment now
				for (String segmentID : segment2scores.keySet()) {
					bw.write("docID " + docId + " segmentID " + segmentID);
					bw.newLine();
					System.out.println("docID " + docId + " segmentID " + segmentID);
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

					int size = Integer.parseInt(docId) - 1;
					scores[size] = Double.NEGATIVE_INFINITY;
					doc2Score.put(Integer.parseInt(docId), Double.NEGATIVE_INFINITY);
					// double[] part = new double[size];
					// System.arraycopy(scores, 0, part, 0, size);
					// int[] biggestElement =
					// indexesOfTopElements(scores,kParameter);
					int counter = 0;
					for (Integer doc : doc2Score.keySet()) {
						if (doc < Integer.parseInt(docId)) {
							if (counter <= kParameter) {
								bw.write("doc " + doc + " " + doc2Score.get(doc));
								bw.newLine();
								System.out.println("doc " + doc + " " + doc2Score.get(doc));
								counter++;
							}
						}
					}
					// System.out.println("");
				}
				bw.write("================================================");
				bw.newLine();
				System.out.println("================================================");
			}

		} catch (NoSuchElementException e) {
			e.printStackTrace();
		}
		bw.close();
	}

	static int[] indexesOfTopElements(double[] orig, int nummax) {
		double[] copy = Arrays.copyOf(orig, orig.length);
		Arrays.sort(copy);
		if (nummax > orig.length) {
			nummax = orig.length;
		}

		double[] honey = Arrays.copyOfRange(copy, copy.length - nummax, copy.length);
		int[] result = new int[nummax];
		int resultPos = 0;
		for (int i = 0; i < orig.length; i++) {
			double onTrial = orig[i];
			int index = Arrays.binarySearch(honey, onTrial);
			if (index < 0)
				continue;
			result[resultPos++] = i;
		}
		return result;
	}
}
