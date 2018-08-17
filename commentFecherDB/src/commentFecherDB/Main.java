package commentFecherDB;

import com.persianp.nlp.process.*;
import com.persianp.nlp.process.Process;

import java.io.*;
import java.nio.ByteBuffer;
import java.nio.charset.Charset;
import java.util.*;

import javax.swing.JOptionPane;

import java.sql.DriverManager;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

public class Main {

	Map<String, Integer> tokenCounts = new HashMap<>();
	@SuppressWarnings("unchecked")
	List<Token>[] myTextTokens = new List[7026];// #docs
	String[] otherFilels = new String[7026];

	public static void main(String[] args) throws SQLException, ClassNotFoundException {

		Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
		Connection conn = DriverManager.getConnection(
				"jdbc:sqlserver://mostafa-vaio\\sqlserver;databaseName=ghatl_dadashi;integratedSecurity=true");
		Statement sta = conn.createStatement();
		String Sql = "select * from AllComments3";
		ResultSet rs = sta.executeQuery(Sql);

		Main mma = new Main();
		mma.preprocess(rs);

	}

	void preprocess(ResultSet rs) {

		try {

			Properties properties = new Properties();
			properties.load(this.getClass().getClassLoader().getResourceAsStream("persianp.properties"));
			Process process = new Process(properties);
			int count = 0;
			int i = 0;
			int jj = 0;
			String otherFieildString;
			while (rs.next()) {

				// System.out.println(rs.getString("new_id"));
				otherFieildString = rs.getString("idkhabar") + "," + rs.getString("pos") + "," + rs.getString("neg");
				otherFilels[jj++] = otherFieildString;

				++i;
				process.process(rs.getString("contents"));
				List<Token> tokens = process.getNonStopwordTokens();
				updateTokenCounts(tokens);
				myTextTokens[count++] = tokens;
			}
			createNextStepFile();
		} catch (Exception e) {
			System.out.println("exception caugth");
			e.printStackTrace();
		}
	}

	private void createNextStepFile() throws IOException {
		FileWriter fw = null;
		BufferedWriter bw = null;
		try {
			fw = new FileWriter("output/stage1NoRes.txt");
			bw = new BufferedWriter(fw);
			bw.write("Cleaned Text:\n");
		} catch (Exception e) {
			System.out.println("error writing to output file");
			e.printStackTrace();
		}
		int i = 0;
		int resCount=0;
		for (List<Token> allAbstract : myTextTokens) {
			i++;
			String[] filedsChunk = otherFilels[(i - 1)].split(",");
			bw.write(filedsChunk[0] + "\t" + filedsChunk[1] + "\t" + filedsChunk[2] + "\t");
			for (Token token : allAbstract) {
				try {

					// k++;
					String temp = null;
					int CleanedCommentCount=0;
					String text = token.getLemma();
//					if (text.equals("وپهلوان"))
//						System.out.println("vapahlvan");
					text.replace("ی", "ي");
					if (token.getTag().equals("RES")) {
//						System.out.println(text);
						++resCount;
					}
					
					if ((!(token.getTag().equals("V")))&(!(token.getTag().equals("PUNC")))& (!(token.getTag().equals("RES")))& (text.length() > 1) & !(token.getTag().equals("NUM"))) {

						bw.write(text + " ");
						CleanedCommentCount++;
					}
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
		}
		try {
			bw.close();
			fw.close();
			System.out.println("Done");
			nullCommentRemover.cleanOutput();
			nullCommentRemover.removeDup();
			System.out.println("RES tag count = "+resCount);
		} catch (Exception e) {
			System.out.println("problem closing file");
			e.printStackTrace();
		}
	}

	private void updateTokenCounts(List<Token> tokens) {
		for (Token token : tokens) {
			String text = token.getText();
			tokenCounts.putIfAbsent(text, 0);
			tokenCounts.replace(text, tokenCounts.get(text) + 1);
		}
	}
}
