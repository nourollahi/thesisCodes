package ir.mostafa.thesis;

import java.io.BufferedReader;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;

public class Tagger {

	public static void main(String[] args) throws IOException {
		InputStream in = new FileInputStream("seemgoodutf8.txt");
		BufferedReader br = new BufferedReader(new InputStreamReader(in, "UTF-8"));
		int i = 0;
		String line;
		while ((line = br.readLine()) != null) {
			String[] splitedLine = line.split("\t");
			
				System.out.println(i+++"-"+splitedLine[4]);
				
			
			}
		}
	}

