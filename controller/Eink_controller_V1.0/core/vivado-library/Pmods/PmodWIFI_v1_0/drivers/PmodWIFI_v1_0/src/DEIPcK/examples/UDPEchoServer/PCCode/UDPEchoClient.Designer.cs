namespace UDPEchoClient
{
    partial class UDPEchoClient
    {
        /// <summary>
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form Designer generated code

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            this.Hostname = new System.Windows.Forms.TextBox();
            this.Port = new System.Windows.Forms.TextBox();
            this.Log = new System.Windows.Forms.RichTextBox();
            this.HostnameLabel = new System.Windows.Forms.Label();
            this.PortLabel = new System.Windows.Forms.Label();
            this.Send = new System.Windows.Forms.Button();
            this.SendTextLabel = new System.Windows.Forms.Label();
            this.SendText = new System.Windows.Forms.TextBox();
            this.ClearLog = new System.Windows.Forms.Button();
            this.SuspendLayout();
            // 
            // Hostname
            // 
            this.Hostname.Location = new System.Drawing.Point(73, 6);
            this.Hostname.Name = "Hostname";
            this.Hostname.Size = new System.Drawing.Size(292, 20);
            this.Hostname.TabIndex = 0;
            this.Hostname.Text = "192.168.1.190";
            // 
            // Port
            // 
            this.Port.Location = new System.Drawing.Point(416, 6);
            this.Port.MaxLength = 5;
            this.Port.Name = "Port";
            this.Port.Size = new System.Drawing.Size(49, 20);
            this.Port.TabIndex = 1;
            this.Port.Text = "44400";
            // 
            // Log
            // 
            this.Log.Location = new System.Drawing.Point(15, 80);
            this.Log.Name = "Log";
            this.Log.ReadOnly = true;
            this.Log.ScrollBars = System.Windows.Forms.RichTextBoxScrollBars.Vertical;
            this.Log.Size = new System.Drawing.Size(450, 266);
            this.Log.TabIndex = 2;
            this.Log.Text = "";
            // 
            // HostnameLabel
            // 
            this.HostnameLabel.AutoSize = true;
            this.HostnameLabel.Location = new System.Drawing.Point(12, 9);
            this.HostnameLabel.Name = "HostnameLabel";
            this.HostnameLabel.Size = new System.Drawing.Size(58, 13);
            this.HostnameLabel.TabIndex = 3;
            this.HostnameLabel.Text = "Hostname:";
            // 
            // PortLabel
            // 
            this.PortLabel.AutoSize = true;
            this.PortLabel.Location = new System.Drawing.Point(381, 9);
            this.PortLabel.Name = "PortLabel";
            this.PortLabel.Size = new System.Drawing.Size(29, 13);
            this.PortLabel.TabIndex = 4;
            this.PortLabel.Text = "Port:";
            // 
            // Send
            // 
            this.Send.Location = new System.Drawing.Point(390, 363);
            this.Send.Name = "Send";
            this.Send.Size = new System.Drawing.Size(75, 23);
            this.Send.TabIndex = 7;
            this.Send.Text = "Send";
            this.Send.UseVisualStyleBackColor = true;
            this.Send.Click += new System.EventHandler(this.Send_Click);
            // 
            // SendTextLabel
            // 
            this.SendTextLabel.AutoSize = true;
            this.SendTextLabel.Location = new System.Drawing.Point(12, 48);
            this.SendTextLabel.Name = "SendTextLabel";
            this.SendTextLabel.Size = new System.Drawing.Size(59, 13);
            this.SendTextLabel.TabIndex = 8;
            this.SendTextLabel.Text = "Send Text:";
            // 
            // SendText
            // 
            this.SendText.Location = new System.Drawing.Point(73, 45);
            this.SendText.Name = "SendText";
            this.SendText.Size = new System.Drawing.Size(392, 20);
            this.SendText.TabIndex = 9;
            this.SendText.Text = "Text to Echo";
            // 
            // ClearLog
            // 
            this.ClearLog.Location = new System.Drawing.Point(15, 363);
            this.ClearLog.Name = "ClearLog";
            this.ClearLog.Size = new System.Drawing.Size(75, 23);
            this.ClearLog.TabIndex = 10;
            this.ClearLog.Text = "Clear Log";
            this.ClearLog.UseVisualStyleBackColor = true;
            this.ClearLog.Click += new System.EventHandler(this.ClearLog_Click);
            // 
            // UDPEchoClient
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(479, 398);
            this.Controls.Add(this.ClearLog);
            this.Controls.Add(this.SendText);
            this.Controls.Add(this.SendTextLabel);
            this.Controls.Add(this.Send);
            this.Controls.Add(this.PortLabel);
            this.Controls.Add(this.HostnameLabel);
            this.Controls.Add(this.Log);
            this.Controls.Add(this.Port);
            this.Controls.Add(this.Hostname);
            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.Fixed3D;
            this.Name = "UDPEchoClient";
            this.Text = "UDPEchoClient";
            this.FormClosing += new System.Windows.Forms.FormClosingEventHandler(this.UDPEchoClient_Close);
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        private System.Windows.Forms.TextBox Hostname;
        private System.Windows.Forms.TextBox Port;
        private System.Windows.Forms.RichTextBox Log;
        private System.Windows.Forms.Label HostnameLabel;
        private System.Windows.Forms.Label PortLabel;
        private System.Windows.Forms.Button Send;
        private System.Windows.Forms.Label SendTextLabel;
        private System.Windows.Forms.TextBox SendText;
        private System.Windows.Forms.Button ClearLog;

        #endregion
    }
}

