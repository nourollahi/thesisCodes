import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.util.HashMap;

public class MainApp {
	public static void main(String[] args) throws Exception {
		BufferedReader br = new BufferedReader(new FileReader(new File("commenResLm.txt")));
		String currentLine;
		HashMap<String, String> commentResLm = new HashMap<>();
		while ((currentLine = br.readLine()) != null) {
			String[] lineParts = currentLine.split("\t");
			String tuple = lineParts[0] + "," + lineParts[1];
			commentResLm.put(tuple, lineParts[2]);
//			System.out.println(lineParts[0] + "," + lineParts[1]+"="+ lineParts[2]);
		}
		br.close();
		BufferedReader br2 = new BufferedReader(new FileReader(new File("LabeledData.csv")));
		currentLine = br2.readLine();
		currentLine = br2.readLine();
		while ((currentLine = br2.readLine()) != null) {
			String[] lineParts = currentLine.split(",");
			String klScore = commentResLm
					.get(lineParts[1].toLowerCase() + "_" + lineParts[0].toLowerCase() + "," + lineParts[4].toLowerCase() + "_" + lineParts[5].toLowerCase());
			System.out.println(lineParts[1].toLowerCase() + "_" + lineParts[0].toLowerCase() + ","
					+ lineParts[4].toLowerCase() + "_" + lineParts[5].toLowerCase() + " = " + klScore);
		}
		br2.close();
	}
}
