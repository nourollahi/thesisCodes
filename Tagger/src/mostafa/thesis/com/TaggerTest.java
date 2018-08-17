/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package mostafa.thesis.com;

import java.awt.Component;
import java.awt.ComponentOrientation;
import java.awt.GridLayout;
import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;
import java.nio.charset.StandardCharsets;
import java.util.Enumeration;
import java.util.HashMap;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.swing.AbstractButton;
import javax.swing.BorderFactory;
import javax.swing.ButtonGroup;
import javax.swing.GroupLayout;
import javax.swing.JDialog;
import javax.swing.JOptionPane;

/**
 *
 * @author Mostafa
 */
public class TaggerTest extends javax.swing.JFrame {
    //public static BufferedReader br;

    public static BufferedReader br;
    int khabarSize = 1698;
    private int lastRowTagged = 0;
    private int CurrentKhabarRow = 0;
    public static HashMap<Integer, Boolean> hasTag = new HashMap<Integer, Boolean>();
    private static HashMap<Integer, String> documents = new HashMap<>();
    private static HashMap<Integer,String> tags = new HashMap<>();
   // private static HashMap<String,String> rowToDocID = new HashMap<>();
    private ButtonGroup bgroup;
    // public static BufferedWriter bwTagFile;

    /**
     * Creates new form TaggerTest
     */
    public TaggerTest() throws Exception{

        try {

            for (int i = 0; i < khabarSize; ++i) {
                hasTag.put(i, false);
            }
            File fileResult = new File("Tags.txt");

            if (fileResult.createNewFile()) {
                
                System.out.println("tags file created!");
            } else {
                System.out.println("File already exists.");
//                //
//                try (InputStreamReader reader =
//             new InputStreamReader(new FileInputStream("Tags.txt"), StandardCharsets.UTF_8))
//                {
//                    String line = "";
//                //int taggedKhabarCount = 0;
//                while ((line = reader.) != null) {
//                    String[] rows = line.split("\t");
//                    lastRowTagged = Integer.parseInt(rows[0]);
//                    tags.put(lastRowTagged-1, rows[1]);
//                    // ++taggedKhabarCount;
//                    //hasTag.put(taggedKhabarCount, true);
//                }
//                CurrentKhabarRow = lastRowTagged;
//                for (int j = 0; j < lastRowTagged; ++j) {
//                    hasTag.put(j, true);
//                }
//                br2.close();
//                }
//                ///
                FileInputStream fis2 = new FileInputStream(fileResult);
                BufferedReader br2 = new BufferedReader(new InputStreamReader(fis2));
                String line = "";
                //int taggedKhabarCount = 0;
                while ((line = br2.readLine()) != null) {
                    String[] rows = line.split("\t");
                    lastRowTagged = Integer.parseInt(rows[0]);
                    tags.put(lastRowTagged-1, rows[1]);
                    // ++taggedKhabarCount;
                    //hasTag.put(taggedKhabarCount, true);
                }
                CurrentKhabarRow = lastRowTagged;
                for (int j = 0; j < lastRowTagged; ++j) {
                    hasTag.put(j, true);
                }
                br2.close();
            }

            FileInputStream fis = null;
            File fin = new File("allNewsPlain.txt");
            fis = new FileInputStream(fin);
            br = new BufferedReader(new InputStreamReader(fis, "UTF-8"));
            String line;
            int docId = 0;
            while ((line = br.readLine()) != null) {

                documents.put(docId, line);
               // String[] lineParts = line.split("\t");
               // rowToDocID.put(docId+"",lineParts[0]);
                docId++;
            }
            br.close();

        } catch (FileNotFoundException ex) {
            Logger.getLogger(TaggerTest.class.getName()).log(Level.SEVERE, null, ex);
        } catch (IOException ex) {
            Logger.getLogger(TaggerTest.class.getName()).log(Level.SEVERE, null, ex);
        }
//      finally
//      {
//            br2.close();
//      }
        initComponents();
    }

    @SuppressWarnings("unchecked")
    // <editor-fold defaultstate="collapsed" desc="Generated Code">//GEN-BEGIN:initComponents
    private void initComponents() {

        jScrollPane1 = new javax.swing.JScrollPane();
        textMatn = new javax.swing.JTextArea();
        bPre = new javax.swing.JButton();
        bNext = new javax.swing.JButton();
        bSubmit = new javax.swing.JButton();
        jLabel1 = new javax.swing.JLabel();
        jLabel2 = new javax.swing.JLabel();
        jLabel3 = new javax.swing.JLabel();
        jLabel4 = new javax.swing.JLabel();
        textKhabargozari = new javax.swing.JTextField();
        textTarikh = new javax.swing.JTextField();
        lableYourTag = new javax.swing.JLabel();
        textTitr = new javax.swing.JTextField();
        jPanel1 = new javax.swing.JPanel();
        jRadioButton6 = new javax.swing.JRadioButton();
        jRadioButton2 = new javax.swing.JRadioButton();
        jRadioButton4 = new javax.swing.JRadioButton();
        jRadioButton5 = new javax.swing.JRadioButton();
        jRadioButton1 = new javax.swing.JRadioButton();
        jLabel5 = new javax.swing.JLabel();
        jLabel6 = new javax.swing.JLabel();
        jLabel7 = new javax.swing.JLabel();
        jLabel8 = new javax.swing.JLabel();

        setDefaultCloseOperation(javax.swing.WindowConstants.EXIT_ON_CLOSE);
        addWindowListener(new java.awt.event.WindowAdapter() {
            public void windowOpened(java.awt.event.WindowEvent evt) {
                formWindowOpened(evt);
            }
        });

        textMatn.setEditable(false);
        textMatn.setColumns(20);
        textMatn.setFont(new java.awt.Font("B Nazanin+ Regular", 0, 24)); // NOI18N
        textMatn.setLineWrap(true);
        textMatn.setRows(1);
        textMatn.setTabSize(3);
        textMatn.setAutoscrolls(false);
        textMatn.setBorder(null);
        textMatn.setPreferredSize(new java.awt.Dimension(500, 1500));
        textMatn.setVerifyInputWhenFocusTarget(false);
        jScrollPane1.setViewportView(textMatn);

        bPre.setText("خبر قبلی");
        bPre.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                bPreActionPerformed(evt);
            }
        });

        bNext.setText("خبر بعدی");
        bNext.setEnabled(false);
        bNext.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                bNextActionPerformed(evt);
            }
        });

        bSubmit.setFont(new java.awt.Font("Tahoma", 1, 18)); // NOI18N
        bSubmit.setText("ثبت برچسب");
        bSubmit.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                bSubmitActionPerformed(evt);
            }
        });

        jLabel1.setFont(new java.awt.Font("Tahoma", 0, 14)); // NOI18N
        jLabel1.setText("برچسب انتخابی شما برای این خبر:");

        jLabel2.setFont(new java.awt.Font("Tahoma", 0, 14)); // NOI18N
        jLabel2.setText("تیتر خبر");

        jLabel3.setFont(new java.awt.Font("Tahoma", 0, 14)); // NOI18N
        jLabel3.setText("خبرگذاری");

        jLabel4.setFont(new java.awt.Font("Tahoma", 0, 14)); // NOI18N
        jLabel4.setText("تاریخ");

        textKhabargozari.setText("jTextField3");

        textTarikh.setText("jTextField4");

        lableYourTag.setFont(new java.awt.Font("Tahoma", 0, 14)); // NOI18N
        lableYourTag.setText("انتخابی نداشته اید");

        textTitr.setFont(new java.awt.Font("Tahoma", 0, 14)); // NOI18N
        textTitr.setText("تیتر خبر");

        jPanel1.setName("برچسب شما:"); // NOI18N

        jRadioButton6.setFont(new java.awt.Font("Tahoma", 0, 14)); // NOI18N
        jRadioButton6.setText("بدون ارتباط");

        jRadioButton2.setFont(new java.awt.Font("Tahoma", 0, 14)); // NOI18N
        jRadioButton2.setText("تحلیلی");
        jRadioButton2.setToolTipText("");
        jRadioButton2.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                jRadioButton2ActionPerformed(evt);
            }
        });

        jRadioButton4.setFont(new java.awt.Font("Tahoma", 0, 14)); // NOI18N
        jRadioButton4.setText("قدیمی");
        jRadioButton4.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                jRadioButton4ActionPerformed(evt);
            }
        });

        jRadioButton5.setFont(new java.awt.Font("Tahoma", 0, 14)); // NOI18N
        jRadioButton5.setText("تقریبا جدید");

        jRadioButton1.setFont(new java.awt.Font("Tahoma", 0, 14)); // NOI18N
        jRadioButton1.setText("جدید");

        javax.swing.GroupLayout jPanel1Layout = new javax.swing.GroupLayout(jPanel1);
        jPanel1.setLayout(jPanel1Layout);
        jPanel1Layout.setHorizontalGroup(
            jPanel1Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(jPanel1Layout.createSequentialGroup()
                .addGap(231, 231, 231)
                .addComponent(jRadioButton6, javax.swing.GroupLayout.DEFAULT_SIZE, 108, Short.MAX_VALUE)
                .addGap(18, 18, 18)
                .addComponent(jRadioButton2, javax.swing.GroupLayout.DEFAULT_SIZE, 90, Short.MAX_VALUE)
                .addGap(18, 18, 18)
                .addComponent(jRadioButton4, javax.swing.GroupLayout.DEFAULT_SIZE, 88, Short.MAX_VALUE)
                .addGap(18, 18, 18)
                .addComponent(jRadioButton5, javax.swing.GroupLayout.DEFAULT_SIZE, 110, Short.MAX_VALUE)
                .addGap(18, 18, 18)
                .addComponent(jRadioButton1, javax.swing.GroupLayout.DEFAULT_SIZE, 78, Short.MAX_VALUE)
                .addContainerGap())
        );
        jPanel1Layout.setVerticalGroup(
            jPanel1Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(javax.swing.GroupLayout.Alignment.TRAILING, jPanel1Layout.createSequentialGroup()
                .addContainerGap(javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                .addGroup(jPanel1Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)
                    .addComponent(jRadioButton6)
                    .addComponent(jRadioButton2)
                    .addComponent(jRadioButton4)
                    .addComponent(jRadioButton5)
                    .addComponent(jRadioButton1))
                .addContainerGap())
        );

        jLabel5.setText("LastTag");

        jLabel6.setText("Current");

        jLabel7.setText("jLabel7");

        jLabel8.setText("jLabel8");

        javax.swing.GroupLayout layout = new javax.swing.GroupLayout(getContentPane());
        getContentPane().setLayout(layout);
        layout.setHorizontalGroup(
            layout.createParallelGroup(javax.swing.GroupLayout.Alignment.TRAILING)
            .addGroup(layout.createSequentialGroup()
                .addGroup(layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                    .addGroup(layout.createSequentialGroup()
                        .addContainerGap()
                        .addGroup(layout.createParallelGroup(javax.swing.GroupLayout.Alignment.TRAILING)
                            .addComponent(jScrollPane1)
                            .addGroup(layout.createSequentialGroup()
                                .addGroup(layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                                    .addGroup(layout.createSequentialGroup()
                                        .addGroup(layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                                            .addComponent(jLabel1)
                                            .addComponent(lableYourTag, javax.swing.GroupLayout.PREFERRED_SIZE, 153, javax.swing.GroupLayout.PREFERRED_SIZE))
                                        .addGap(67, 67, 67)
                                        .addGroup(layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                                            .addGroup(layout.createSequentialGroup()
                                                .addComponent(jLabel6)
                                                .addGap(18, 18, 18)
                                                .addComponent(jLabel8))
                                            .addGroup(layout.createSequentialGroup()
                                                .addComponent(jLabel5)
                                                .addGap(18, 18, 18)
                                                .addComponent(jLabel7)))
                                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED, 470, Short.MAX_VALUE)
                                        .addGroup(layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                                            .addComponent(textTarikh, javax.swing.GroupLayout.Alignment.TRAILING, javax.swing.GroupLayout.PREFERRED_SIZE, 194, javax.swing.GroupLayout.PREFERRED_SIZE)
                                            .addComponent(textKhabargozari, javax.swing.GroupLayout.Alignment.TRAILING, javax.swing.GroupLayout.PREFERRED_SIZE, 194, javax.swing.GroupLayout.PREFERRED_SIZE)))
                                    .addComponent(textTitr))
                                .addGap(15, 15, 15)
                                .addGroup(layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                                    .addGroup(layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                                        .addGroup(layout.createSequentialGroup()
                                            .addGap(27, 27, 27)
                                            .addComponent(jLabel2))
                                        .addComponent(jLabel3, javax.swing.GroupLayout.Alignment.TRAILING))
                                    .addGroup(javax.swing.GroupLayout.Alignment.TRAILING, layout.createSequentialGroup()
                                        .addGap(64, 64, 64)
                                        .addComponent(jLabel4))))))
                    .addGroup(javax.swing.GroupLayout.Alignment.TRAILING, layout.createSequentialGroup()
                        .addComponent(bPre)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                        .addComponent(bSubmit, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                        .addComponent(bNext))
                    .addGroup(javax.swing.GroupLayout.Alignment.TRAILING, layout.createSequentialGroup()
                        .addGap(0, 0, Short.MAX_VALUE)
                        .addComponent(jPanel1, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)))
                .addContainerGap())
        );
        layout.setVerticalGroup(
            layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(layout.createSequentialGroup()
                .addGroup(layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                    .addComponent(jLabel2)
                    .addComponent(textTitr, javax.swing.GroupLayout.PREFERRED_SIZE, 31, javax.swing.GroupLayout.PREFERRED_SIZE))
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addGroup(layout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)
                    .addComponent(jLabel3)
                    .addComponent(textKhabargozari, javax.swing.GroupLayout.PREFERRED_SIZE, 31, javax.swing.GroupLayout.PREFERRED_SIZE)
                    .addComponent(jLabel1)
                    .addComponent(jLabel5)
                    .addComponent(jLabel7))
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addGroup(layout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)
                    .addComponent(jLabel4)
                    .addComponent(textTarikh, javax.swing.GroupLayout.PREFERRED_SIZE, 32, javax.swing.GroupLayout.PREFERRED_SIZE)
                    .addComponent(lableYourTag)
                    .addComponent(jLabel6)
                    .addComponent(jLabel8))
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(jScrollPane1, javax.swing.GroupLayout.DEFAULT_SIZE, 456, Short.MAX_VALUE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(jPanel1, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addGroup(layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                    .addComponent(bSubmit, javax.swing.GroupLayout.PREFERRED_SIZE, 45, javax.swing.GroupLayout.PREFERRED_SIZE)
                    .addComponent(bNext, javax.swing.GroupLayout.PREFERRED_SIZE, 45, javax.swing.GroupLayout.PREFERRED_SIZE)
                    .addComponent(bPre, javax.swing.GroupLayout.PREFERRED_SIZE, 45, javax.swing.GroupLayout.PREFERRED_SIZE))
                .addContainerGap())
        );

        pack();
    }// </editor-fold>//GEN-END:initComponents

    private void jRadioButton2ActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_jRadioButton2ActionPerformed
        // TODO add your handling code here:
    }//GEN-LAST:event_jRadioButton2ActionPerformed
    private void bSubmitActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_bSubmitActionPerformed
        bPre.setEnabled(true);
        String tag = getSelectedButtonText(bgroup);
        System.out.println(tag);
        if (!(tag.equals("no-tag"))) {
            if (!(hasTag.get(CurrentKhabarRow))) {
                
                try{
                writeTagOnFile(tag);
                }catch (Exception e){
                    e.printStackTrace();
                }
                tags.put(lastRowTagged, tag);
                lastRowTagged++;
            } else {
                //payami mabni bar inke khabar tag darad :)
                 
               try{
                writeTagOnFile(tag);
                }catch (Exception e){
                    e.printStackTrace();
                }
                tags.put(--CurrentKhabarRow, tag);
                CurrentKhabarRow++;
                Component frame = null;
                JOptionPane.showMessageDialog(frame, "tag updated");
            }
            readNextKhabar();
        } else {
            //payami mabni bar entekhab y chizi!!
            //System.out.println("select some things");
            System.out.println(lastRowTagged);
            Component frame = null;
            JOptionPane.showMessageDialog(frame, "select tag plz:)");
        }
        
    }//GEN-LAST:event_bSubmitActionPerformed

    
  
    private void jRadioButton4ActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_jRadioButton4ActionPerformed
        // TODO add your handling code here:
    }//GEN-LAST:event_jRadioButton4ActionPerformed

    private void formWindowOpened(java.awt.event.WindowEvent evt) {//GEN-FIRST:event_formWindowOpened
        textMatn.setComponentOrientation(ComponentOrientation.RIGHT_TO_LEFT);
        textTitr.setComponentOrientation(ComponentOrientation.RIGHT_TO_LEFT);
        textTarikh.setComponentOrientation(ComponentOrientation.RIGHT_TO_LEFT);
        jPanel1.setBorder(BorderFactory.createTitledBorder(
                BorderFactory.createEtchedBorder(), "برچسب مورد نظر شما:"));
        bgroup = new ButtonGroup();
        bgroup.add(jRadioButton1);
        bgroup.add(jRadioButton2);
        bgroup.add(jRadioButton6);
        bgroup.add(jRadioButton4);
        bgroup.add(jRadioButton5);
        jPanel1.setLayout(new GridLayout(1, 5));;
        jPanel1.add(jRadioButton1);
        jPanel1.add(jRadioButton2);
        jPanel1.add(jRadioButton4);
        jPanel1.add(jRadioButton5);
        jPanel1.add(jRadioButton6);

        //  textKhabargozari.setComponentOrientation(ComponentOrientation.RIGHT_TO_LEFT);
//      try 
//           FileInputStream fis = null;
//           File fin = new File("in.txt");
//            fis = new FileInputStream(fin);
//            BufferedReader br = new BufferedReader(new InputStreamReader(fis,"UTF-8"));
//            BufferedReader in = new BufferedReader(new InputStreamReader(stream, encoding));
        System.out.println(lastRowTagged);
//      for (int i=0;i<RowTagged+1;++i)
//      {
//                //br.readLine();
//      } 
        readNextKhabar();
    }//GEN-LAST:event_formWindowOpened

    private void bPreActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_bPreActionPerformed
        // TODO add your handling code here:
        CurrentKhabarRow--;
        jLabel8.setText(CurrentKhabarRow+"");
        bNext.setEnabled(true);
//         if (CurrentKhabarRow<lastRowTagged)
//        {
//           // bSubmit.setEnabled(false);
//        }
         if(CurrentKhabarRow==0)
         {
             bPre.setEnabled(false);
         }
        String line;
        line = documents.get((CurrentKhabarRow + 1));
            String[] khabar = line.split("\t");
            textKhabargozari.setText(khabar[1]);
            textTarikh.setText(khabar[3]);
            textTitr.setText(khabar[4]);
            textMatn.setText(khabar[5]);
            lableYourTag.setText(tags.get(CurrentKhabarRow));
            
    }//GEN-LAST:event_bPreActionPerformed

    private void bNextActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_bNextActionPerformed
        // TODO add your handling code here:
        CurrentKhabarRow++;
        jLabel8.setText(CurrentKhabarRow+"");
        readNextKhabar();
        if (CurrentKhabarRow== lastRowTagged)
        {
            bNext.setEnabled(false);
            bSubmit.setEnabled(true);
        }
        bPre.setEnabled(true);
    }//GEN-LAST:event_bNextActionPerformed

//    catch (IOException e)
//    {
//            System.err.println("formWindowOpened Error: "+e);
//    }
    // }
    public static void main(String args[]) {
        /* Set the Nimbus look and feel */
        //<editor-fold defaultstate="collapsed" desc=" Look and feel setting code (optional) ">
        /* If Nimbus (introduced in Java SE 6) is not available, stay with the default look and feel.
         * For details see http://download.oracle.com/javase/tutorial/uiswing/lookandfeel/plaf.html 
         */
        try {
            for (javax.swing.UIManager.LookAndFeelInfo info : javax.swing.UIManager.getInstalledLookAndFeels()) {
                if ("Nimbus".equals(info.getName())) {
                    javax.swing.UIManager.setLookAndFeel(info.getClassName());
                    break;
                }
            }
        } catch (ClassNotFoundException ex) {
            java.util.logging.Logger.getLogger(TaggerTest.class.getName()).log(java.util.logging.Level.SEVERE, null, ex);
        } catch (InstantiationException ex) {
            java.util.logging.Logger.getLogger(TaggerTest.class.getName()).log(java.util.logging.Level.SEVERE, null, ex);
        } catch (IllegalAccessException ex) {
            java.util.logging.Logger.getLogger(TaggerTest.class.getName()).log(java.util.logging.Level.SEVERE, null, ex);
        } catch (javax.swing.UnsupportedLookAndFeelException ex) {
            java.util.logging.Logger.getLogger(TaggerTest.class.getName()).log(java.util.logging.Level.SEVERE, null, ex);
        }
        //</editor-fold>

        /* Create and display the form */
        java.awt.EventQueue.invokeLater(new Runnable() {
            public void run() {
                try{
                new TaggerTest().setVisible(true);
            
                }catch(Exception e)
                {
                    e.printStackTrace();
                }
            }
        });
    }

    // Variables declaration - do not modify//GEN-BEGIN:variables
    private javax.swing.JButton bNext;
    private javax.swing.JButton bPre;
    private javax.swing.JButton bSubmit;
    private javax.swing.JLabel jLabel1;
    private javax.swing.JLabel jLabel2;
    private javax.swing.JLabel jLabel3;
    private javax.swing.JLabel jLabel4;
    private javax.swing.JLabel jLabel5;
    private javax.swing.JLabel jLabel6;
    private javax.swing.JLabel jLabel7;
    private javax.swing.JLabel jLabel8;
    private javax.swing.JPanel jPanel1;
    private javax.swing.JRadioButton jRadioButton1;
    private javax.swing.JRadioButton jRadioButton2;
    private javax.swing.JRadioButton jRadioButton4;
    private javax.swing.JRadioButton jRadioButton5;
    private javax.swing.JRadioButton jRadioButton6;
    private javax.swing.JScrollPane jScrollPane1;
    private javax.swing.JLabel lableYourTag;
    private javax.swing.JTextField textKhabargozari;
    private javax.swing.JTextArea textMatn;
    private javax.swing.JTextField textTarikh;
    private javax.swing.JTextField textTitr;
    // End of variables declaration//GEN-END:variables

    private void readNextKhabar() {

        try {

            //System.out.println("rowtag= "+RowTagged);
            //if(RowTagged==0)
            //  br.readLine();
            String line;
            // line = br.readLine();
            // System.out.println(line);
            if (CurrentKhabarRow == 0) {
                // RowTagged++;
            }

            line = documents.get((CurrentKhabarRow + 1));
            String[] khabar = line.split("\t");
            textKhabargozari.setText(khabar[1]);
            textTarikh.setText(khabar[3]);
            textTitr.setText(khabar[4]);
            textMatn.setText(khabar[5]);
            textMatn.setCaretPosition(0);
            if (CurrentKhabarRow<lastRowTagged)
            lableYourTag.setText(tags.get(CurrentKhabarRow));
            else
             lableYourTag.setText("انتخابی نداشته اید");
            jLabel7.setText(lastRowTagged+"");
            jLabel8.setText(CurrentKhabarRow+"");
        } catch (Exception e) {
            System.err.println("readNextKhabar()" + e);
            //some things change here!!!
        }
    }

    private void writeTagOnFile(String tag) throws Exception {
        BufferedWriter bw = null;
        try {
            // System.out.println(CurrentKhabarRow);
            bw = new BufferedWriter(new FileWriter("Tags.txt", true));
            bw.append((CurrentKhabarRow + 1) + "\t" + tag);
            bw.newLine();
            bw.flush();
            hasTag.put(CurrentKhabarRow, true);
            CurrentKhabarRow = CurrentKhabarRow + 1;
            //lastRowTagged = lastRowTagged + 1;
        } catch (IOException ioe) {
            ioe.printStackTrace();
        } finally {
            if (bw != null) {
                try {
                    bw.close();
                } catch (IOException ioe2) {
                    // just ignore it
                }
            }
        }
// try (OutputStreamWriter writer =
//             new OutputStreamWriter(new FileOutputStream("Tags.txt"), StandardCharsets.UTF_8)){
//            writer.append((CurrentKhabarRow + 1) + "\t" + tag);
//            writer.write("\n");
//            writer.flush();
//            hasTag.put(CurrentKhabarRow, true);
//            CurrentKhabarRow = CurrentKhabarRow + 1;
//            }
    }

    public String getSelectedButtonText(ButtonGroup buttonGroup) {
        for (Enumeration<AbstractButton> buttons = buttonGroup.getElements(); buttons.hasMoreElements();) {
            AbstractButton button = buttons.nextElement();

            if (button.isSelected()) {
                return button.getText();
            }
        }

        return "no-tag";
    }
}
