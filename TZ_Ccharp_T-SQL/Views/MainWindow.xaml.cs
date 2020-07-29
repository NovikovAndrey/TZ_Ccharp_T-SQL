using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.CompilerServices;
using System.Text;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Shapes;
using TZ_Ccharp_T_SQL.Controller;

namespace TZ_Ccharp_T_SQL.View
{
    /// <summary>
    /// Interaction logic for MainWindow.xaml
    /// </summary>
    public partial class MainWindow : Window
    {
        private string FilePath;
        public MainWindow()
        {
            InitializeComponent();
        }

        private void Button_Click(object sender, RoutedEventArgs e)
        {
            FilePath = HomeController.GetFile();
            if (FilePath != null)
            {
                FilePathTextBox.Text = FilePath;
            }
        }

        private void SearchButton_Click(object sender, RoutedEventArgs e)
        {
            try
            {
                ResultsTextBox.Text = "";
                var homeController = new HomeController();
                var ListResults = homeController.SearchRequest(FilePath, XPathTextBox.Text);
                if(ListResults.Count == 0)
                {
                    ResultsTextBox.Visibility = Visibility.Collapsed;
                    throw new Exception("По заданному выражению ничего не найдено!");
                }
                foreach (string vs in ListResults)
                {
                    ResultsTextBox.Visibility = Visibility.Visible;
                    ResultsTextBox.Text += vs;
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message);
            }
        }
    }
}
