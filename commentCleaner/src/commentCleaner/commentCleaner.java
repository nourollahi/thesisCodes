package commentCleaner;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Properties;
import com.persianp.nlp.process.Process;
import com.persianp.nlp.process.Token;

public class commentCleaner {

	Map<String, Integer> tokenCounts = new HashMap<>();
	@SuppressWarnings("unchecked")
	List<Token>[] myTextTokens = new List[7110];// #docs
	String[] otherFilels = new String[7110];
	// List<String> mostFrequentTokens = new ArrayList<>(100);
	String[] khabarId = new String [7110];

	public static void main(String[] args) throws SQLException, ClassNotFoundException {

		// Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
		// //Connection conn =
		// DriverManager.getConnection("jdbc:sqlserver://localhost;user=;password=;database=ghatl_dadashi");
		// Connection conn =
		// DriverManager.getConnection("jdbc:sqlserver://mostafa-vaio\\sqlserver;databaseName=ghatl_dadashi;integratedSecurity=true");
		// Statement sta = conn.createStatement();
		// String Sql = "select * from khabar ORDER BY [year] asc, [month] asc,
		// [day] asc, [hour] asc, [minute] asc";
		// ResultSet rs = sta.executeQuery(Sql);

		commentCleaner mma = new commentCleaner();
		mma.preprocess();

	}

	void preprocess() {

		try {

			Properties properties = new Properties();
			properties.load(this.getClass().getClassLoader().getResourceAsStream("persianp.properties"));
			Process process = new Process(properties);
			InputStream in = new FileInputStream("input/sortedComment-utf8.txt");
			// BufferedReader br = new BufferedReader(new FileReader(new
			// File("input/sortedComment-utf8.txt")));
			BufferedReader br = new BufferedReader(new InputStreamReader(in, "UTF-8"));
			// String line;
			int count = 0;
			// int i=0;
			// int jj=0;
			// String otherFieildString;
			String tempLine;
			String[] commentLine = null;
			while ((tempLine = br.readLine()) != null) {

				// System.out.println(rs.getString("new_id"));
				// otherFieildString =
				// rs.getString("id")+","+rs.getString("new_id")+","+rs.getString("khabar_gozari")+","+rs.getString("year")+","+rs.getString("month")+","+rs.getString("day")+","+rs.getString("hour")+","+rs.getString("minute");
				// otherFilels[jj++]=otherFieildString;
				commentLine = tempLine.split("\t");
				process.process(commentLine[1]);
				List<Token> tokens = process.getNonStopwordTokens();
				updateTokenCounts(tokens);
				myTextTokens[count] = tokens;
				khabarId[count++]=commentLine[0];
			}
			// while ((line = br.readLine()) != null) {
			// ++i;
			// process.process(line);
			// List<Token> tokens = process.getNonStopwordTokens();
			// updateTokenCounts(tokens);
			// myTextTokens[count++] = tokens;
			// }

			// br.close();

			// determineMostFrequentTokens();
			createNextStepFile(khabarId);
		} catch (Exception e) {
			System.out.println("exception caugth");
			e.printStackTrace();
		}
	}

	private void createNextStepFile(String[] khabarId) throws IOException {
		FileWriter fw = null;
		BufferedWriter bw = null;
		try {
			fw = new FileWriter("output/outputText-Test.txt");
			bw = new BufferedWriter(fw);
			bw.write("Cleaned Text:\n");
		} catch (Exception e) {
			System.out.println("error writing to output file");
			e.printStackTrace();
		}
		int i = 0;
		double allAverage = 0;
		for (List<Token> allAbstract : myTextTokens) {

			int termLen = 0;
			int termCount = 0;
			//i++;
			// String[] filedsChunk = otherFilels[(i-1)].split(",");
			bw.write(khabarId[i]+"\t");
			++i;
			for (Token token : allAbstract) {
				try {

					// k++;
					String temp = null;
					// String text = token.getLemma();
					String text = token.getText();
					System.out.println(text);
					// ( iftoken.getTag().equals("RES"))
					// RESCounter++;
					// System.out.println(token.getText() + "\t\t\t" +
					// token.getLemma() + "\t\t\t" + token.getTag());

					// if (!mostFrequentTokens.contains(text)) {
					// text.replace(" ", "-");
					// if (text.contains("«")){
					// temp = text.replaceAll("«", "");
					// text=temp;
					// }
					// if (text.contains("»")){
					// temp = text.replaceAll("»", "");
					// text=temp;
					// }
					if ((!(token.getTag().equals("PUNC"))) & token.getText().length()<20) {
						termLen += text.length();
						termCount++;
						bw.write(text + " ");
					}

					// }
				} catch (IOException e) {
					System.out.println("failed to write token to file");
					e.printStackTrace();
				}
			}
			try {
				bw.write("\n");

			} catch (IOException e) {
				System.out.println("failed to write endofline to file");
				e.printStackTrace();
			}
			double docAverage = (double) termLen / termCount;
			allAverage += docAverage;
			System.out.println("doc " + i + " average term length=" + (docAverage));
		}
		System.out.println("collection average = " + allAverage / 240);
		try {
			bw.close();
			fw.close();
			System.out.println("Done");
		} catch (Exception e) {
			System.out.println("problem closing file");
			e.printStackTrace();
		}
	}

	// private void determineMostFrequentTokens() {
	// int[] counts = new int[100];
	// for(Map.Entry entry: tokenCounts.entrySet()) {
	// for(int i = 0; i<30; i++){
	// if((Integer)entry.getValue() > counts[i]){
	// mostFrequentTokens.add(i, (String)entry.getKey());
	// counts[i] = (Integer)entry.getValue();
	// break;
	// }
	// }
	// }
	//
	// mostFrequentTokens = mostFrequentTokens.subList(0, numOfFreqTerm);
	// for (int i = 0; i < numOfFreqTerm; i++) {
	// System.out.println(mostFrequentTokens.get(i));
	// }
	// }

	private void updateTokenCounts(List<Token> tokens) {
		for (Token token : tokens) {
			String text = token.getText();
			tokenCounts.putIfAbsent(text, 0);
			tokenCounts.replace(text, tokenCounts.get(text) + 1);
		}
	}
}
